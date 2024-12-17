local OutgoingMessage = require("neuro_game_sdk.messages.api.outgoing_message")

require("neuro_game_sdk.utils.table_utils")

local ActionsRegister = setmetatable({}, { __index = OutgoingMessage })
ActionsRegister.__index = ActionsRegister

function ActionsRegister:new(actions)
    local obj = OutgoingMessage.new(self)
    obj._actions = actions or {}
    return obj
end

function ActionsRegister:_get_command()
    return "actions/register"
end

function ActionsRegister:_get_data()
    return { actions = self._actions }
end

function ActionsRegister:merge(other)
    if getmetatable(other) ~= ActionsRegister then
        return false
    end
    self._actions = table.filter(self._actions, function(my_action)
        return not table.any(other._actions, function(their_action)
            return my_action.name == their_action.name
        end)
    end)

    for _, their_action in ipairs(other._actions) do
        table.insert(self._actions, their_action)
    end

    return true
end

return ActionsRegister