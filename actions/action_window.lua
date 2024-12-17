local ActionsForce = require("neuro_game_sdk.messages.outgoing.action_force")

local Context = require("neuro_game_sdk.messages.outgoing.context")
local NeuroActionHandler = require("neuro_game_sdk.actions.neuro_action_handler")
local WebsocketConnection = require("neuro_game_sdk.websocket.websocket_connection")

State = {
    BUILDING = 1,
    REGISTERED = 2,
    FORCED = 3,
    ENDED = 4
}

local ActionWindow = {}
ActionWindow.__index = ActionWindow

function ActionWindow:new()
    local obj = {
        _state = State.BUILDING,
        _force_enabled = false,
        _force_timeout = 0.0,
        _action_force_query = "",
        _action_force_state = "",
        _action_force_ephemeral_context = false,
        _end_enabled = false,
        _end_timeout = 0.0,
        _actions = {}, -- of 'type' NeuroAction[]
        _context_enabled = false,
        _context_message = "",
        _context_silent = false,
        _timer = 0.0,
        _list_index = #ActionWindowsList
    }
    setmetatable(obj, ActionWindow)
    table.insert(ActionWindowsList, obj)
    return obj
end

function ActionWindow:set_force(timeout, query, state, ephemeral_context)
    if not self:_validate_frozen() then
        return
    end

    self._force_enabled = true
    self._force_timeout = timeout
    self._action_force_query = query
    self._action_force_state = state
    self._action_force_ephemeral_context = ephemeral_context
end

function ActionWindow:set_end(end_timeout)
    if not self:_validate_frozen() then
        return
    end

    self._end_enabled = true
    self._end_timeout = end_timeout
end

function ActionWindow:set_context(message, silent)
    if not self:_validate_frozen() then
        return
    end
    silent = silent or false -- default value is false
    self._context_enabled = true
    self._context_message = message
    self._context_silent = silent
end

function ActionWindow:add_action(action)
    if not self:_validate_frozen() then
        return
    end

    if action:can_be_used() then
        table.insert(self._actions, action)
    end
end

function ActionWindow:register()
    if self._state ~= State.BUILDING then
        print("Cannot register an ActionWindow more than once.")
        return
    end

    if #self._actions == 0 then
        print("Cannot register an ActionWindow with no actions.")
        return
    end

    if self._context_enabled then
        Context.send(self._context_message, self._context_silent)
    end
    NeuroActionHandler.register_actions(self._actions)

    self._state = State.REGISTERED
end

function ActionWindow:result(execution_result)
    if self._state == State.BUILDING then
        print("Cannot handle a result before registering.")
    elseif self._state == State.ENDED then
        print("Cannot handle a result after the ActionWindow has ended.")
    elseif execution_result.successful then
        self:_end()
    elseif self._state == State.FORCED then
        -- Neuro is now responsible for retrying failed action forces
    end
    return execution_result;
end

function ActionWindow:_validate_frozen()
    if self._state ~= State.BUILDING then
        print("Tried to mutate action after it was registered")
        return false
    end
    return true
end

function ActionWindow:update(delta)
    if self._state ~= State.REGISTERED then
        return
    end

    self._timer = self._timer + delta

    if self._force_enabled and self._timer >= self._force_timeout then
        self._state = State.FORCED
        self._force_enabled = false
        self:_send_force()
    end

    if self._end_enabled and self._timer >= self._end_timeout then
        self:_end()
    end
end

function ActionWindow:_send_force()
    local array = table.map(self._actions, function (action)
        return action:get_name()
    end)
    WebsocketConnection.send(ActionsForce:new(self._action_force_query, self._action_force_state,
        self._action_force_ephemeral_context, array))
end

function ActionWindow:_end()
    NeuroActionHandler.unregister_actions(self._actions)
    self._end_enabled = false;
    self._state = State.ENDED
    table.remove(ActionWindowsList, self._list_index)
    self = nil
    collectgarbage()
end

return ActionWindow
