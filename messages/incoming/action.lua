local JSON = require("neuro_game_sdk.third_party.json")
local IncomingMessage = require("neuro_game_sdk.messages.api.incoming_message")
local ExecutionResult = require("neuro_game_sdk.websocket.execution_result")
local IncomingData = require("neuro_game_sdk.messages.api.incoming_data")
local NeuroActionHandler = require("neuro_game_sdk.actions.neuro_action_handler")
local WebsocketConnection = require("neuro_game_sdk.websocket.websocket_connection")
local ActionResult = require("neuro_game_sdk.messages.outgoing.action_result")

local Action = setmetatable({}, { __index = IncomingMessage })
Action.__index = Action

function Action:new()
    local obj = setmetatable({}, self)
    return obj
end

function Action:_can_handle(command)
    return command == 'action'
end

function Action:_validate(_command, message_data, state)
    if message_data == nil then
        return ExecutionResult.vedal_failure(Strings.action_failed_no_data)
    end

    local action_id = message_data:get_string("id")
    if not action_id then
        return ExecutionResult.vedal_failure(Strings.action_failed_no_id)
    end

    state._action_id = action_id

    local action_name = message_data:get_string("name")
    local action_stringified_data = message_data:get_string("data", "{}")

    if action_name == nil or action_name == "" then
        return ExecutionResult.vedal_failure(Strings.action_failed_no_name)
    end

    local action = NeuroActionHandler.get_action(action_name)
    if action == nil then
        if NeuroActionHandler.is_recently_unregistered(action_name) then
            return ExecutionResult.failure(Strings.action_failed_unregistered)
        end
        return ExecutionResult.failure(Strings.action_failed_unknown_action(action_name))
    end

    state._action_instance = action

    local success, parsed_data = pcall(JSON.decode, action_stringified_data)
    if not success then
        return ExecutionResult.failure(Strings.action_failed_invalid_json)
    end

    if type(parsed_data) ~= 'table' then
        print("Action data can only be a table. Other respones are not permitted for the API implementation in Love2d.")
        return ExecutionResult.failure(Strings.action_failed_invalid_json)
    end

    local action_data = IncomingData:new(parsed_data)

    local result = action:validate(action_data, state)
    return result
end

function Action:_report_result(state, result)
    local id = state["_action_id"]
    if id == nil then
        print(string.format(
            "Action.report_result received no action id. It probably could not be parsed in the action. Received result: %s",
            result.message))
        return
    end

    WebsocketConnection.send(ActionResult:new(id, result))
end

function Action:_execute(state)
    local action = state._action_instance
    action:execute(state)
end

return Action
