# Neuro lua package

Luarocks package that implements [Neuro-sama game API](https://github.com/VedalAI/neuro-game-sdk)

This package was mainly targeted for [Love2D engine](https://love2d.org/).

Generally it should be possible to use it in anything Lua related as long as you have access to the following game lifecycle hooks:
- Init/Start/Awake/Ready - called on game initialization
- Update/Process - game loop function that is usually called every frame
- Destroy/Exit - called before game closing


>[!NOTE]  
>I'm by no means an experienced Lua dev, this project it my first exposure to Lua language and I've finished it in like ~4 days, so code quality all over the place and out of the window.<br>
>If you are an experienced Lua dev I would be glad to get a code review and read your suggestions.


> [!CAUTION]  
> Currently there's an issue with reconnecting and timeouts on websockets.  
> If the app starts before the server, it takes approximately 2 minutes to reconnect. I tried simple solutions like using copas.timeout or setting the timeout parameter on the socket, but they didn't help. Further investigation is required.

This package uses coroutine based websockets from [this package](https://github.com/lipp/lua-websockets)

# Installation and Setup

> [!WARNING]  
> I've only tested those steps on Windows 11. If you're using something else, you're on your own. <br>
> If you were successful on other platforms or encountered problems with my instructions, feel free to open a Pull Request or an Issue accordingly.

## Prerequisites
- Lua 5.1
- Luarocks
- Likely some compilers from MinGW, so install MinGW

## Installation

### Luarocks method

1. Open cmd and run following command 

 ```
 luarocks --lua-version=5.1 install neuro-game-sdk
 ``` 
Package and it's dependencies should be downloaded and unpacked to your appdata\roaming\luarocks folder

### Manually (in case there's an issue with **this** luarocks package)

1. Download this repo
2. Open cmd in the root of the repo folder and run following command 
```
luarocks --lua-version=5.1 make
```
Dependencies should be downloaded and unpacked to your appdata\roaming\luarocks folder, this package should be also 'build' and placed there.

## Setup
>[!NOTE]
>This sections will only provide instructions for Love2D engine

To use this package your Lua files need to know where to look for dependencies. You can specify additional paths for Love2D to look up:
1. Open cmd and run following command

``` 
luarocks --lua-version=5.1 path
```
2. Copy hude string from a terminal to a notepad of your choice 
    
    2.1. Remove row that starts with `SET "PATH=`, we don't need this 
    
    2.2. Remove `SET ` from the start of both rows. 
    
    2.3. Remove `LUA_PATH=` and `LUA_CPATH=`. 
    
    2.4. Then you should be left with two strings that contains some paths separated by `;`, that's what we need.
3. Create a file called like `luarocks-paths.lua` and paste your strings like in the template below (also check "Building Love2D game with SDK" section below):
```lua
love.filesystem.setRequirePath(
        "your 1st string goes here" ..
        "your 2nd string goes here"
)
```
4. Add following line to your main file. Now your Love2D should properly resolve paths from dependencies and you can `require` them wihtout failing a build.

```lua 
require('luarocks_paths')
```

5. You need to add/set environment variable `neuro_sdk_WS_URL` in your system to `127.0.0.1:8000` or `ws://127.0.0.1:8000` (Sdk will add `ws://` if missing, idk if this could be a problem in case `wss://` is passed)

# Usage
To learn how to use the SDK read [this doc](USAGE.md)

## Building Love2D game with SDK
 To build app with this luarocks package you need to:
1. copy content of following folders to lib folder in the root of you game project:   
``%AppData%\Roaming\luarocks\share\lua\5.1``  
``%AppData%\Roaming\luarocks\lib\lua\5.1``
2. Make this call in your main.lua as early as possible, you can add first `require` of the file containing this code:
```lua
love.filesystem.setRequirePath(
        "?.lua;" ..
        "?/init.lua;" ..
        "lib/?.lua;" ..
        "lib/?/init.lua;"
)
```
3. Follow steps from official [docs](https://love2d.org/wiki/Game_Distribution)

# Example
For working game "Tic Tac Toe by AlexejheroDev" reimplementation example in Love2D you can check [this folder](examples/tic tac toe) and get built version from release
