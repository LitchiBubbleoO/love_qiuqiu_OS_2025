local json = require("json")
local Protocol = {}

-- 命令类型
Protocol.CMD = {
    LOGIN = "login",
    REGISTER = "register",
    CREATE_ROOM = "create_room",
    JOIN_ROOM = "join_room",
    LEAVE_ROOM = "leave_room",
    ROOM_LIST = "room_list",
    PLAYER_MOVE = "player_move",
    GAME_UPDATE = "game_update",
    CHAT = "chat",
    HEARTBEAT = "heartbeat",
    ONLINE_COUNT = "online_count"
}

-- 打包消息
function Protocol.packMessage(cmd, data)
    local message = {
        cmd = cmd,
        data = data or {}
    }
    
    local jsonStr = json.encode(message)
    local len = string.len(jsonStr)
    
    -- 大端序，前2字节为长度
    local lenBytes = string.char(math.floor(len / 256), len % 256)
    return lenBytes .. jsonStr
end

-- 解析消息
function Protocol.parseMessage(data)
    if #data < 2 then return nil end
    
    -- 读取长度
    local len = string.byte(data, 1) * 256 + string.byte(data, 2)
    
    if #data >= 2 + len then
        local jsonStr = string.sub(data, 3, 2 + len)
        local success, message = pcall(json.decode, jsonStr)
        
        if success and message.cmd then
            return message, 2 + len
        end
    end
    
    return nil
end

return Protocol