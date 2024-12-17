local NeuroSdkConfig = require("neuro_game_sdk.config")
local CommandHandler = {}
CommandHandler.__index = CommandHandler

function CommandHandler:new()
    local obj = setmetatable({
        handlers = {}
    }, self)
    return obj
end

function CommandHandler:register_all()
    for _, module_name in ipairs(NeuroSdkConfig.incoming_msg_modules) do
        local script = require(module_name)
        if script ~= nil then
            local message = script:new()
            table.insert(self.handlers, message)
            print(string.format("Added websocket message Handler: %s", module_name))
        end
    end
end

function CommandHandler:handle(command, data)
    for _, handler in ipairs(self.handlers)
    do
        if handler:can_handle(command) then
            local state = {}
            local validation_result = handler:validate(command, data, state)
            if not validation_result.successful then
                print("Received unsuccessful execution result when handling a message")
                print(validation_result.message)
            end
            handler:report_result(state, validation_result)

            if validation_result.successful then
                handler:execute(state)
            end
        end
    end
end

return CommandHandler
