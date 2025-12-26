local socket = require("socket")
local json = require("json")
local Protocol = require("protocol")

local game_setting = require("game_setting")

local Client = {
    connected = false,
    socket = nil,
    buffer = "",
    userInfo = nil,
    onMessageCallback = nil,
    onConnectCallback = nil,
    onDisconnectCallback = nil,
    latency = nil, -- 网络延迟（毫秒）
    heartbeatTimer = 0, -- 心跳计时器
    heartbeatInterval = 1.0, -- 心跳间隔（秒）
    -- 重连相关
    reconnectEnabled = false, -- 是否启用自动重连
    reconnectTimer = 0, -- 重连计时器
    reconnectInterval = game_setting.reconnect_interval or 3.0, -- 重连间隔（秒）
    reconnectHost = nil, -- 重连服务器地址
    reconnectPort = nil -- 重连服务器端口
}

function Client:connect(host, port)
    -- 保存服务器地址用于重连
    self.reconnectHost = host
    self.reconnectPort = port
    
    self.socket = socket.tcp()
    -- 使用短超时进行连接
    self.socket:settimeout(2)
    
    local success, err = self.socket:connect(host, port)
    
    if success == 1 then
        -- 连接成功，设置为非阻塞模式用于接收数据
        self.socket:settimeout(0)
        self.connected = true
        self.reconnectTimer = 0 -- 重置重连计时器
        self.buffer = "" -- 清空buffer，避免旧数据干扰
        if self.onConnectCallback then
            self.onConnectCallback()
        end
        print("连接到服务器: " .. host .. ":" .. port)
        return true
    else
        print("连接失败: " .. tostring(err))
        if self.socket then
            self.socket:close()
            self.socket = nil
        end
        return false
    end
end

function Client:disconnect()
    if self.socket then
        self.socket:close()
        self.socket = nil
    end
    self.connected = false
    self.buffer = ""
    self.latency = nil
    self.heartbeatTimer = 0
    -- 注意：不断开时重置重连计时器，让重连机制继续工作
    
    if self.onDisconnectCallback then
        self.onDisconnectCallback()
    end
end

-- 启用自动重连
function Client:enableReconnect(host, port)
    self.reconnectEnabled = true
    self.reconnectHost = host or self.reconnectHost
    self.reconnectPort = port or self.reconnectPort
    self.reconnectTimer = 0 -- 立即尝试重连
end

-- 禁用自动重连
function Client:disableReconnect()
    self.reconnectEnabled = false
    self.reconnectTimer = 0
end

function Client:update(dt)
    -- 如果未连接且启用了自动重连，尝试重连
    if not self.connected and self.reconnectEnabled and self.reconnectHost and self.reconnectPort then
        self.reconnectTimer = self.reconnectTimer + dt
        if self.reconnectTimer >= self.reconnectInterval then
            print("尝试重连服务器: " .. self.reconnectHost .. ":" .. self.reconnectPort)
            self.reconnectTimer = 0 -- 重置计时器
            self:connect(self.reconnectHost, self.reconnectPort)
        end
        return -- 未连接时不处理其他逻辑
    end
    
    if not self.connected or not self.socket then return end
    
    -- 心跳检测
    self.heartbeatTimer = self.heartbeatTimer + dt
    if self.heartbeatTimer >= self.heartbeatInterval then
        self:sendHeartbeat()
        self.heartbeatTimer = 0
    end
    
    -- 接收数据，非阻塞模式下尝试接收最多4096字节
    -- 使用receive("*a")接收所有可用数据，但非阻塞模式下可能返回nil
    local data, err, partial = self.socket:receive(4096)
    
    -- 处理接收到的数据
    local receivedData = nil
    if data then
        receivedData = data
    elseif partial and #partial > 0 then
        -- partial数据也需要处理
        receivedData = partial
    end
    
    if receivedData then
        self.buffer = self.buffer .. receivedData
        
        -- 防止buffer无限增长（如果超过64KB，说明可能有问题）
        if #self.buffer > 65536 then
            print("警告: buffer过大，清空buffer")
            self.buffer = ""
        end
        
        -- 解析buffer中的所有完整消息
        while true do
            local message, consumed = Protocol.parseMessage(self.buffer)
            if not message then break end
            
            -- print("Client:update parsed message:", message.cmd)
            self.buffer = string.sub(self.buffer, consumed + 1)
            
            if self.onMessageCallback then
                self.onMessageCallback(message)
            end
        end
    elseif err and err ~= "timeout" then
        print("接收错误: " .. err)
        self:disconnect()
    end
end

function Client:send(cmd, data)
    if not self.connected or not self.socket then 
        print("Client:send failed - not connected")
        return false 
    end
    
    local packet = Protocol.packMessage(cmd, data)
    -- print("Client:send", cmd, "packet size:", #packet)
    local success, err = self.socket:send(packet)
    
    if not success then
        print("发送失败: " .. tostring(err))
        self:disconnect()
        return false
    end
    
    -- print("Client:send success")
    return true
end

function Client:login(username, password)
    return self:send(Protocol.CMD.LOGIN, {
        username = username,
        password = password
    })
end

function Client:register(username, password)
    print("Client:register called", username, password)
    local result = self:send(Protocol.CMD.REGISTER, {
        username = username,
        password = password
    })
    print("Client:register send result", result)
    return result
end

function Client:createRoom(roomName, password, maxPlayers)
    return self:send(Protocol.CMD.CREATE_ROOM, {
        name = roomName,
        password = password or "",
        maxPlayers = maxPlayers or 50
    })
end

function Client:joinRoom(roomId, password)
    return self:send(Protocol.CMD.JOIN_ROOM, {
        roomId = roomId,
        password = password or ""
    })
end

function Client:requestRoomList()
    return self:send(Protocol.CMD.ROOM_LIST, {})
end

function Client:leaveRoom()
    return self:send(Protocol.CMD.LEAVE_ROOM, {})
end

-- 请求在线人数
function Client:requestOnlineCount()
    return self:send(Protocol.CMD.ONLINE_COUNT, {})
end

function Client:sendMove(x, y)
    -- print(string.format("Client:sendMove called: x=%.2f y=%.2f", x, y))
    return self:send(Protocol.CMD.PLAYER_MOVE, {
        x = x,
        y = y
    })
end

-- 发送心跳包
function Client:sendHeartbeat()
    if not self.connected then return end
    
    -- 获取当前时间戳（毫秒）
    local timestamp = love.timer.getTime() * 1000
    return self:send(Protocol.CMD.HEARTBEAT, {
        timestamp = timestamp
    })
end

-- 处理心跳响应
function Client:handleHeartbeat(data)
    if data and data.timestamp then
        -- 计算延迟：当前时间 - 发送时间
        local currentTime = love.timer.getTime() * 1000
        local latency = currentTime - data.timestamp
        self.latency = math.max(0, math.floor(latency))
    end
end

return Client