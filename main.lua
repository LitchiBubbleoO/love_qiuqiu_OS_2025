local game_setting = require("game_setting")

local SceneManager = {
    current = nil,
    scenes = {}
}

function love.load()
    love.window.setMode(game_setting.window_width, game_setting.window_height, {resizable=false})

    local success, font = pcall(love.graphics.newFont, "assets/fonts/font.otf", 16)
     if success then
         chineseFont = font
         print("成功加载中文字体")
     else
         -- 回退到默认字体
         chineseFont = love.graphics.newFont(18)
         print("字体加载失败，使用默认字体")
     end
     love.graphics.setFont(chineseFont)

    -- 注册场景
    SceneManager.scenes = {
        login = require("scenes.login"),
        rooms = require("scenes.rooms"),
        room = require("scenes.room"),
        game = require("scenes.game")
    }
    
    -- 初始化场景
    for name, scene in pairs(SceneManager.scenes) do
        if scene.init then scene:init() end
    end
    
    -- 切换到登录界面
    SceneManager.switchTo("login")
end

function SceneManager.switchTo(sceneName, ...)
    if SceneManager.current and SceneManager.current.leave then
        SceneManager.current:leave()
    end
    
    SceneManager.current = SceneManager.scenes[sceneName]
    
    if SceneManager.current and SceneManager.current.enter then
        SceneManager.current:enter(...)
    end
end

function love.update(dt)
    if SceneManager.current and SceneManager.current.update then
        SceneManager.current:update(dt)
    end
end

function love.draw()
    if SceneManager.current and SceneManager.current.draw then
        SceneManager.current:draw()
    end
end

function love.keypressed(key)
    if SceneManager.current and SceneManager.current.keypressed then
        SceneManager.current:keypressed(key)
    end
end

function love.keyreleased(key)
    if SceneManager.current and SceneManager.current.keyreleased then
        SceneManager.current:keyreleased(key)
    end
end

function love.mousepressed(x, y, button)
    if SceneManager.current and SceneManager.current.mousepressed then
        SceneManager.current:mousepressed(x, y, button)
    end
end

function love.textinput(text)
    if SceneManager.current and SceneManager.current.textinput then
        SceneManager.current:textinput(text)
    end
end

-- 导出SceneManager
_G.SceneManager = SceneManager