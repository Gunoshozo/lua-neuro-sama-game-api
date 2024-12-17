local Startup = require("neuro_game_sdk.messages.outgoing.startup")

local MessageQueue = {}
MessageQueue.__index = MessageQueue

function MessageQueue:new()
    local obj = setmetatable({
        _messages = {},
    }, self)
    table.insert(obj._messages, Startup:new())
    return obj
end

function MessageQueue:size()
    return #self._messages
end

function MessageQueue:enqueue(message)
    for _, existing_message in ipairs(self._messages)
    do
        if existing_message.merge(message) then
            return
        end
    end
    table.insert(self._messages, message)
end

function MessageQueue:dequeue()
    if #self._messages == 0 then
        return nil
    end
    return table.remove(self._messages, 1)
end

return MessageQueue
