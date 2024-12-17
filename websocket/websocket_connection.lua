local copas = require('copas')

local MessageQueue = require("neuro_game_sdk.websocket.message_queue")
local CommandHandler = require("neuro_game_sdk.websocket.command_handler")
local IncomingData = require("neuro_game_sdk.messages.api.incoming_data")
local JSON = require("neuro_game_sdk.third_party.json")
local websocket = require 'websocket'

local WebsocketConnection = {}
WebsocketConnection._socket = nil
WebsocketConnection._message_queue = MessageQueue:new()
WebsocketConnection._command_handler = nil
WebsocketConnection.__index = WebsocketConnection
WebsocketConnection._elapsed_time = 0

local WebSocketTimeout = 5

function WebsocketConnection:new()
    WebsocketConnection._command_handler = CommandHandler:new()
    WebsocketConnection._command_handler.name = "Command Handler"
    WebsocketConnection._command_handler:register_all();

    local obj = setmetatable({}, self)
    return obj
end

function WebsocketConnection:load()
    copas.addthread(function()
        while true do
            if WebsocketConnection._socket == nil or WebsocketConnection._socket.state == "CLOSED" then
                WebsocketConnection._socket = nil
                self:_ws_start()
            end
            copas.sleep(0.1)
        end
    end)

    copas.addthread(function()
        self:_ws_read()
    end)

    copas.addthread(function()
        while true do
            if WebsocketConnection._socket ~= nil and WebsocketConnection._socket.state == "OPEN" then
                self:_ws_write()
            end
            copas.sleep(0.1)
        end
    end)
end

function WebsocketConnection:update(delta)
    copas.step()
end

function WebsocketConnection:_ws_start()
    ::restart::
    print("Initializing Websocket connection")
    if WebsocketConnection._socket ~= nil then
        local state = WebsocketConnection._socket.state
        print(1, state)
        if state == "OPEN" or state == "CONNECTING" then
            WebsocketConnection._socket:close()
        end
    end

    local ws_url = os.getenv("neuro_sdk_WS_URL")
    if ws_url == nil then
        print("neuro_sdk_WS_URL environment variable is not set")
        return
    else
        local prefix = "ws://"
        local also_possible_prefix = "wss://" -- idk app might explode
        -- checking for ws:// or wss://
        if string.sub(ws_url, 1, #prefix) ~= prefix and string.sub(ws_url, 1, #also_possible_prefix) ~= also_possible_prefix then
            ws_url = prefix .. ws_url
        end
    end


    WebsocketConnection._socket = websocket.client.copas({ timeout = WebSocketTimeout })

    -- local success, err = WebsocketConnection._socket:connect(ws_url, 'echo')
    local success, err = pcall(function()
        return WebsocketConnection._socket:connect(ws_url, 'any')
    end)
    if not success then
        print(string.format("Could not connect to websocket, error code %s", err))
        WebsocketConnection._socket = nil
        copas.sleep(3)
        goto restart
    else 
        print("Successfully connected")
    end
end

function WebsocketConnection:_ws_reconnect()
    WebsocketConnection._socket = nil
    copas.sleep(3)
    self:_ws_start()
end

-- todo rewrite if else if else
-- this bs is written that way since Lua don't have an actiual continue and for goto I need to reorder variable declarations
function WebsocketConnection:_ws_read()
    while true do
        if WebsocketConnection._socket ~= nil and WebsocketConnection._socket.state == "OPEN" then
            local msg, opcode, close_was_clean, close_code, close_reason = WebsocketConnection._socket:receive()
            if close_was_clean ~= nil and close_code ~= nil and close_reason ~= nil then
                print(string.format("Error while reading code: %d reason: %s clean: %s", close_code, close_reason,
                    tostring(close_was_clean)))
            elseif opcode ~= 1 then
                print("Websocket message was not sent as a text")
            else
                local success, parsed_data = pcall(JSON.decode, msg)
                if not success then
                    print(string.format("Could not parse websocket message: %s", msg))
                elseif type(parsed_data) ~= "table" then
                    print(string.format("Websocket message is not a table: %s", msg))
                else
                    local message = IncomingData:new(parsed_data)
                    local command = message:get_string("command")

                    if not command then
                        print(string.format("Websocket message does not have a command: %s", msg))
                    else
                        local data = message:get_object("data", {})
                        WebsocketConnection._command_handler:handle(command, data)
                    end
                end
            end
        end
        copas.sleep(0.01)
    end
end

function WebsocketConnection:_ws_write()
    while WebsocketConnection._message_queue:size() > 0 do
        local outMsg = WebsocketConnection._message_queue:dequeue()
        WebsocketConnection._send_internal(outMsg:get_ws_message())
    end
end

function WebsocketConnection.send(message)
    WebsocketConnection._message_queue:enqueue(message)
end

function WebsocketConnection.send_immediate(message)
    if WebsocketConnection._socket == nil or WebsocketConnection._socket.state ~= "OPEN" then
        print("Cannot send immediate message, websocket is not connected")
        return
    end
    WebsocketConnection._send_internal(message:get_ws_message())
end

function WebsocketConnection._send_internal(message)
    local string_data = JSON.encode(message:get_data())
    WebsocketConnection._socket:send(string_data, 1)
end

return WebsocketConnection
