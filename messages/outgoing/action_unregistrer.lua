local OutgoingMessage = require("neuro_game_sdk.messages.api.outgoing_message")
require("neuro_game_sdk.utils.table_utils")

local ActionsUnregister = setmetatable({}, { __index = OutgoingMessage })
ActionsUnregister.__index = ActionsUnregister

function ActionsUnregister:new(actions)
    local obj = OutgoingMessage.new(self)
    obj._names = table.map(actions, function(action) return action.name end)
    return obj
end

function ActionsUnregister:_get_command()
    return "actions/unregister"
end

function ActionsUnregister:_get_data()
    return { action_names = self._names }
end

function ActionsUnregister:merge(other)
    if getmetatable(other) ~= ActionsRegister then
        return false
    end
    self._names = table.filter(self._names, function(my_name)
        return not table.any(other._names, function(other_name)
            return other_name == my_name
        end)
    end)

    for _, their_action in ipairs(other._actions) do
        table.insert(self._names, their_action)
    end

    return true
end


return ActionsUnregister