local NeuroSdkConfig = require("neuro_game_sdk.config")
local WsMessage = require("neuro_game_sdk.messages.api.ws_message")

local OutgoingMessage = {}
OutgoingMessage.__index = OutgoingMessage

function OutgoingMessage:new()
    local obj = setmetatable({}, self)
    return obj
end

function OutgoingMessage:_get_command()
    print("Error: OutgoingMessage._get_command() is not implemented.")
    return "invalid"
end

function OutgoingMessage:_get_data()
    return {}
end

function OutgoingMessage:merge(_other)
    return false
end

function OutgoingMessage:get_ws_message()
    return WsMessage:new(self:_get_command(), self:_get_data(), NeuroSdkConfig.game)
end

return OutgoingMessage
