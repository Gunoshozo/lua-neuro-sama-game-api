local copas = require('copas')
local WebsocketConnection = require("neuro_game_sdk.websocket.websocket_connection")
local NeuroActionHandler = require("neuro_game_sdk.actions.neuro_action_handler")

local GameHooks = {}

ActionWindowsList = {}

local WebsocketConnectionInstance = nil
local NeuroActionHandlerInstance = nil

-- need to call this method in your 'game loop'/'update' method (e.g love.update)
function update(delta)
    for _, ActionWindow in ipairs(ActionWindowsList)
    do
        if ActionWindow ~= nil then
            ActionWindow:update(delta)
        end
    end
    if WebsocketConnectionInstance ~= nil then
        WebsocketConnectionInstance:update(delta)
    end
end

-- need to call this method in your initialization code (e.g love.load)
function load()
    WebsocketConnectionInstance = WebsocketConnection:new()
    WebsocketConnectionInstance:load()
    NeuroActionHandlerInstance = NeuroActionHandler.getInstance()
end

function quit()
    copas.addthread(function()
        if NeuroActionHandlerInstance ~= nil then
            NeuroActionHandlerInstance:quit()
        end
    end)

    copas.step()
end

GameHooks.update = update
GameHooks.load = load
GameHooks.quit = quit

return GameHooks
