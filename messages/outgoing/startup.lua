local OutgoingMessage = require("neuro_game_sdk.messages.api.outgoing_message")

local Startup = setmetatable({}, { __index = OutgoingMessage })
Startup.__index = Startup

function Startup:_get_command()
    return "startup"
end

return Startup