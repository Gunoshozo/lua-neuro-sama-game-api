local ExecutionResult = require("neuro_game_sdk.websocket.execution_result")
local WsAction = require("neuro_game_sdk.actions.ws_action")

local NeuroAction = {}
NeuroAction.__index = NeuroAction

function NeuroAction:new(action_window)
    local obj = setmetatable({
        _action_window = action_window
    }, self)
    return obj
end

function NeuroAction:get_name()
    return self:_get_name()
end

function NeuroAction:can_be_used()
    return self:_can_be_used()
end

function NeuroAction:validate(data, state)
    if self._action_window ~= nil then
        return self._action_window:result(self:_validate_action(data, state))
    end
    return self:_validate_action(data, state)
end

function NeuroAction:execute(state)
    self:_execute_action(state)
end

function NeuroAction:get_ws_action()
    return WsAction:new(self:_get_name(), self:_get_description(), self:_get_schema())
end

function NeuroAction:_get_name()
    print("Action._get_name() is not implemented.")
    return ""
end

function NeuroAction:_get_description()
    print("Action._get_description() is not implemented.")
    return ""
end

function NeuroAction:_get_schema()
    print("Action._get_schema() is not implemented.")
    return {}
end

function NeuroAction:_can_be_used()
    return true
end

function NeuroAction:_validate_action(data, _state)
    print("Action._validate_action() is not implemented.")
    return ExecutionResult.mod_failure("Action._validate_action() is not implemented.")
end

function NeuroAction:_execute_action(state)
    print("Action._execute_action() is not implemented.")
end

return NeuroAction