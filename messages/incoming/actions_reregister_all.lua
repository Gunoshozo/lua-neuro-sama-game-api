local ExecutionResult = require("neuro_game_sdk.websocket.execution_result")
local IncomingMessage = require("neuro_game_sdk.messages.api.incoming_message")
local NeuroActionHandler = require("neuro_game_sdk.actions.neuro_action_handler")


local ActionsReregisterAll = setmetatable({}, { __index = IncomingMessage })
ActionsReregisterAll.__index = ActionsReregisterAll

function ActionsReregisterAll:new()
    local obj = setmetatable({},self)
    return obj
end


function ActionsReregisterAll:_can_handle(command)
    return command == "actions/reregister_all"
end

function ActionsReregisterAll:_validate(_command, _data, _state)
    return ExecutionResult.success()
end

function ActionsReregisterAll:_report_result(state, result)
end

function ActionsReregisterAll:_execute(_state)
    NeuroActionHandler.resend_registered_actions()
end

return ActionsReregisterAll