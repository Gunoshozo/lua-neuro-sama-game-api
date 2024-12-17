local OutgoingMessage = require("neuro_game_sdk.messages.api.outgoing_message")

local ActionsForce = setmetatable({}, { __index = OutgoingMessage })
ActionsForce.__index = ActionsForce

function ActionsForce:new(query, state, ephemeral_context, action_names)
    local obj = OutgoingMessage.new(self)
    obj._query = query
    obj._state = state
    obj._ephemeral_context = ephemeral_context
    obj._action_names = action_names
    return obj
end

function ActionsForce:_get_command()
    return "actions/force"
end

function ActionsForce:_get_data()
    return {
        query = self._query,
        state = self._state,
        ephemeral_context = self._ephemeral_context,
        action_names = self._action_names
    }
end

return ActionsForce
