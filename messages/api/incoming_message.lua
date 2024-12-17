local ExecutionResult = require("neuro_game_sdk.websocket.execution_result")

local IncomingMessage = {}
IncomingMessage.__index = IncomingMessage

function IncomingMessage:can_handle(command)
    return self:_can_handle(command)
end

function IncomingMessage:validate(command, message_data, state)
    local result = self:_validate(command, message_data, state)
    if result == nil then
        print("IncomingMessage._validate() returned null. An error probably occurred.")
        return ExecutionResult.mod_failure(Strings.action_failed_error)
    end
    return result
end

function IncomingMessage:report_result(state, result)
    self:_report_result(state, result)
end

function IncomingMessage:execute(state)
    self:_execute(state)
end

function IncomingMessage:_can_handle(command)
    print("IncomingMessage._can_handle() is not implemented.")
    return false
end

function IncomingMessage:_validate(command, message_data, state)
    print("IncomingMessage._validate() is not implemented.")
    return ExecutionResult.mod_failure("IncomingMessage.validate() is not implemented.")
end

function IncomingMessage:_report_result(state, result)
    print("IncomingMessage._report_result() is not implemented.")
end

function IncomingMessage:_execute(state)
    print("IncomingMessage._execute() is not implemented.")
end


return IncomingMessage