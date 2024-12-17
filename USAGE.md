# Usage

>[!NOTE]  
>I'm not going to go into the details of the api, I'm going to give examples and explain how to work with this implementation of SDK specifically, for more info about API and specs please refer to original docs [here](https://github.com/VedalAI/neuro-game-sdk/blob/main/API/README.md) and [here](https://github.com/VedalAI/neuro-game-sdk/blob/main/API/SPECIFICATION.md). <br>
For more explanations you can check [official Godot SDK usage doc](https://github.com/VedalAI/neuro-game-sdk/blob/main/Godot/USAGE.md) since this SDK is heavily based on it

## About module paths

If you don't know what path to `require` check `neuro-game-sdk-X.Y.Z-1.rockspec` in the root of this repo

<details>
<summary> 
Explanations of all module paths 
</summary>

**You are REQUIRED to use these**<br>
_"neuro_game_sdk.config"_        -- global config for sdk, don't touch anything but 'game' field <br>
_"neuro_game_sdk.game_hooks"_    -- function for game lifecycle hooks (load, update, quit)<br>


**You NEED to use these for your custom logic**<br>
_"neuro_game_sdk.actions.action_window"_ -- action window, you need it to adding action, _settings forces, and registering actions<br>
_"neuro_game_sdk.actions.neuro_action"_ -- interface that you need to implement for your _custom actions<br> 
_"neuro_game_sdk.websocket.execution_result"_ -- used for telling Neuro if action is _successful of failed<br>
_"neuro_game_sdk.string_consts"_ -- string constants that are used in SDK, and can be used _for messages template <br>
_"neuro_game_sdk.utils.json_utils"_   -- json utils needed for schema<br>
_"neuro_game_sdk.actions.neuro_action_handler"_ -- **INTERNAL** singleton, you can manually register and unregister actions with it <br>


**You CAN to use these if you feel like it**<br>
_"neuro_game_sdk.utils.table_utils"_  -- utils that extend default table API with methods 'filter', 'any', 'map', 'get_keys' for JSpilled people<br>
_"neuro_game_sdk.third_party.json"_   -- 3rd party dependency  <a href="https://github.com/rxi/json.lua">source</a> <br>

**You likely don't need those. Look, but don't mess with them**<br>
_"neuro_game_sdk.actions.ws_action"_  -- **INTERNAL** used to format actions before sending via websocket<br>
_"neuro_game_sdk.websocket.websocket_connection"_ -- **INTERNAL** singleton, responsible for websocket stuff<br>
_"neuro_game_sdk.websocket.command_handler"_ -- **INTERNAL** handle commands<br>
_"neuro_game_sdk.websocket.message_queue"_  --  **INNERNAL** queue for websocket messages <br>

**Interfaces, names speak for themselfs**<br> 
_"neuro_game_sdk.messages.api.incoming_data"_ <br>
_"neuro_game_sdk.messages.api.incoming_message"_ <br>
_"neuro_game_sdk.messages.api.outgoing_message"_ <br>
_"neuro_game_sdk.messages.api.ws_message"_    <br>

**Messages that Neuro could send to client**<br>
_"neuro_game_sdk.messages.incoming.action"_<br>
_"neuro_game_sdk.messages.incoming.actions_reregister_all"_<br>

**Messages that client could send to Neuro**<br>
_"neuro_game_sdk.messages.outgoing.action_force"_ <br>
_"neuro_game_sdk.messages.outgoing.action_result"_<br>
_"neuro_game_sdk.messages.outgoing.action_unregistrer"_<br>
_"neuro_game_sdk.messages.outgoing.actions_register"_ <br>
_"neuro_game_sdk.messages.outgoing.context"_ <br>
_"neuro_game_sdk.messages.outgoing.startup"_   

</details>

https://Love2D.org/wiki/Game_Distribution

## Game lifecycle hooks
To integrate SDK in your game you need to import couple modules and use them as follows (example for Love2D)
```lua
local GameHooks = require("neuro_game_sdk.game_hooks")
local SDKConfig = require("neuro_game_sdk.config")

-- game initialization 
function love.load()
    SDKConfig.game = "Tic tac toe"  -- set your game's name, so it will be passed in websocket packages
    GameHooks.load()                -- SKD's initialization logic
    -- your code goes here
end

-- game main loop called each frame
function love.update(delta)         
    GameHooks.update(delta);        -- SDK's main loop logic, put it here so SDK can perform it's periodic tasks
    -- your code goes here
end


-- game is closing
function love.quit()
    GameHooks.quit()                -- SDK's logic for gracefull shutdown (mainly unregistering actions)
    -- your code goes here
end
```

## Implementing your own actions

For the minimal example you can check [this file](/examples/tic%20tac%20toe/custom_actions/play_o_action.lua) and examples from [main SDK repo](https://github.com/VedalAI/neuro-game-sdk), classes are similar to a digree.

### Genaral example
```lua
-- import NeuroAction "class"
local NeuroAction = require("neuro_game_sdk.actions.neuro_action")
-- this is needed for creating schema
local JsonUtils = require("neuro_game_sdk.utils.json_utils")
-- with this you will tell Neuro if her action was successully executed or failed
local ExecutionResult = require("neuro_game_sdk.websocket.execution_result")

-- "inherit" base "class" NeuroAction
local MyCustomAction = setmetatable({}, { __index = NeuroAction })
MyCustomAction.__index = MyCustomAction

-- define constructor
function MyCustomAction:new(action_window, action_related_data)
    -- call "base class" constructor 
    local obj = NeuroAction.new(self, action_window)
    -- initialize fields that you think you will need for your action
    obj.action_related_data = action_related_data
    return obj
end

-- you NEED to define this method to give your action a name, otherwise it will be an empty string
function MyCustomAction:_get_name()
    return "play"
end

-- you NEED to define this method to give your action a description, otherwise it will be empty string
function MyCustomAction:_get_description()
    return "Your custom action"
end

-- you NEED to define this method to give your action a schema, otherwise your schema will be {}
function MyCustomAction:_get_schema()
    return JsonUtils.wrap_schema({
        -- just an example from "Tic Tac Toe", could be arbitrary valid json represented in form of Lua's table
        cell = {
            enum = self:_get_available_cells()
        }
    })
end

-- you NEED to define this method, otherwise it will return ExecutionResult.mod_failure("Action._validate_action() is not implemented.")
function MyCustomAction:_validate_action(data, state)
    -- your code goes here
    -- you need to check that `data` argument contains valid schema and it's a valid action in context of your game and it's state

    -- you need to modify `state` argument, since it will be passed to the `_execute_action` mathod below
    state["data_for_action"] = {info="very Important data"}

    -- you can return either of following ExecutionResults:
    ExecutionResult.success(message)

    ExecutionResult.failure(message)

    ExecutionResult.vedal_failure(message)

    ExecutionResult.mod_failure(message)

    -- all branches of your code should return some ExecutionResult!
    return ExecutionResult.success()
end

-- you NEED to define this method, otherwise nothing will happend in the game
function MyCustomAction:_execute_action(state)
    -- you can extract data from provided state
    local info = state["data_for_action"].info
    -- and do something with that you provided in the constructor to affect the game state
    -- I guess you will need to provide some callback/function in `action_related_data` to execute it here
    self.action_related_data.some_method(info)
end

-- don't forget to return your "class" if you are using this style of imports
-- local MyClass = require("module.path.to.MyClass")
return MyCustomAction
```

## Sending info to Neuro

> [!NOTE]   
> SDK puts [startup](https://github.com/VedalAI/neuro-game-sdk/blob/main/API/SPECIFICATION.md#startup) message in message queue by defailt

### Giving Neuro some context, sending text messages
[More about Context](https://github.com/VedalAI/neuro-game-sdk/blob/main/API/SPECIFICATION.md#context)
```lua
-- this class is used for sending general info to Neuro
local Context = require("neuro_game_sdk.messages.outgoing.context")

--- this method is used for sending info to Neuro
Context.send(message, silent)
```

### Actions

Code sample from my Tic Tac Toe [example](/examples/tic%20tac%20toe/main.lua), for more info about action windows read [official Godot SKD docs](https://github.com/VedalAI/neuro-game-sdk/blob/main/Godot/USAGE.md#action-windows)

```lua
local ActionWindow = require("neuro_game_sdk.actions.action_window")

local actionWindow = ActionWindow:new()
actionWindow:set_force(0.0, "It is your turn. Please place an O.", "", false)
actionWindow:add_action(PlayOAction:new(actionWindow, { grid = grid, make_a_move = make_a_move }))
actionWindow:register()
```

You can unregister actions like this, for more info read [official Godot SKD docs](https://github.com/VedalAI/neuro-game-sdk/blob/main/Godot/USAGE.md#registered-actions)
```lua
--imports required for this
local NeuroActionHandler = require("neuro_game_sdk.actions.neuro_action_handler")
local MyCustomAction = require("path.to.yourCustomAction")
local MyCustomAction1 = require("path.to.yourCustomAction1")

NeuroActionHandler.unregister_actions({MyCustomAction:new(), MyCustomAction1:new()})
```
