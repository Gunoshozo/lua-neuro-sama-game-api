local OutgoingMessage = require("neuro_game_sdk.messages.api.outgoing_message")

local ActionsForce = setmetatable({}, { __index = OutgoingMessage })
ActionsForce.__index = ActionsForce

ActionsForce.Priority = {
    LOW = 1,
    MEDIUM = 2,
    HIGH = 3,
    CRITICAL = 4
}

local PRIORITY_MAP = {
    [ActionsForce.Priority.LOW] = "low",
    [ActionsForce.Priority.MEDIUM] = "medium",
    [ActionsForce.Priority.HIGH] = "high",
    [ActionsForce.Priority.CRITICAL] = "critical"
}

function ActionsForce:new(query, state, ephemeral_context, action_names, priority)
    priority = priority or ActionsForce.Priority.LOW
    assert(PRIORITY_MAP[priority], string.format("Invalid priority value: %s", tostring(priority)))

    local obj = OutgoingMessage.new(self)
    obj._query = query
    obj._state = state
    obj._ephemeral_context = ephemeral_context
    obj._action_names = action_names
    obj._priority = priority
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
        action_names = self._action_names,
        priority = PRIORITY_MAP[self._priority]
    }
end

return ActionsForce
