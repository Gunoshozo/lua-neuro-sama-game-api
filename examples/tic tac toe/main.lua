require('luarocks_paths')

local ActionsForce = require("neuro_game_sdk.messages.outgoing.action_force")
local Context = require("neuro_game_sdk.messages.outgoing.context")
local GameHooks = require("neuro_game_sdk.game_hooks")
local SDKConfig = require("neuro_game_sdk.config")
local ActionWindow = require("neuro_game_sdk.actions.action_window")
local PlayOAction = require("custom_actions.play_o_action")
local SFX = require("sfx")

-- game related variables
local GRID_SIZE = 3
local CELL_PADDING = 10
local MAX_GRID_SIZE = 600
local windowWidth = 1080
local windowHeight = 1080 - MAX_GRID_SIZE / 3 + 50

-- game state variables
local grid = {}
local currentPlayer = "X"
local winner = nil
local cells_left = 9;


function love.load()
    SDKConfig.game = "Tic tac toe"

    GameHooks.load()

    love.window.setMode(windowWidth, windowHeight, { resizable = true })
    love.window.setTitle("Tic tac toe")

    initialize_grid();
end

function love.update(delta)
    GameHooks.update(delta)
end

function love.quit()
    GameHooks.quit()
end

function love.draw()
    local effectiveCellSize = get_effective_cell_size()
    local totalGridSize = effectiveCellSize * GRID_SIZE + CELL_PADDING * (GRID_SIZE - 1)
    local offsetX = (windowWidth - totalGridSize) / 2
    local offsetY = (windowHeight - totalGridSize) / 2

    local fontSize = effectiveCellSize * 0.5
    love.graphics.setNewFont(fontSize)


    love.graphics.setBackgroundColor(0.3, 0.3, 0.3, 1)

    -- draw grid
    for i = 1, GRID_SIZE do
        for j = 1, GRID_SIZE do
            local x = offsetX + (j - 1) * (effectiveCellSize + CELL_PADDING)
            local y = offsetY + (i - 1) * (effectiveCellSize + CELL_PADDING)

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", x, y, effectiveCellSize, effectiveCellSize)

            local cellValue = grid[i][j]
            if cellValue ~= "" then
                love.graphics.setColor(0, 0, 0)
                love.graphics.printf(cellValue, x, y + effectiveCellSize / 4.5, effectiveCellSize, "center")
                love.graphics.setColor(1, 1, 1)
            end
        end
    end

    -- draw reset button
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", windowWidth / 2 - totalGridSize / 2, windowHeight - effectiveCellSize,
        totalGridSize, effectiveCellSize)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("RESET", windowWidth / 2 - totalGridSize / 2, windowHeight - effectiveCellSize * 0.7,
        totalGridSize, "center")
end

function love.resize(w, h)
    windowWidth = w
    windowHeight = h
end

function love.mousepressed(x, y, button)
    -- left button click
    if button == 1 then
        local effectiveCellSize = get_effective_cell_size()
        local totalGridSize = effectiveCellSize * GRID_SIZE + CELL_PADDING * (GRID_SIZE - 1)
        local offsetX = (windowWidth - totalGridSize) / 2

        -- handle reset button click
        local topOfButton = windowHeight - effectiveCellSize
        if x >= offsetX and x <= offsetX + totalGridSize and y >= topOfButton and y <= windowHeight then
            reset_game()
        end

        -- hanlde cell click
        if currentPlayer == "X" and cells_left ~= 0 and winner == nil then
            local offsetY = (windowHeight - totalGridSize) / 2
            if x >= offsetX and x <= offsetX + totalGridSize and y >= offsetY and y <= offsetY + totalGridSize then
                -- mumbo jumbo optimizations to minimize number of iterations
                local rowStart = math.floor((y - offsetY) / (effectiveCellSize + CELL_PADDING)) + 1
                local colStart = math.floor((x - offsetX) / (effectiveCellSize + CELL_PADDING)) + 1
                for row = rowStart, math.min(rowStart + 1, GRID_SIZE) do
                    for col = colStart, math.min(colStart + 1, GRID_SIZE) do
                        local cellX = offsetX + (col - 1) * (effectiveCellSize + CELL_PADDING)
                        local cellY = offsetY + (row - 1) * (effectiveCellSize + CELL_PADDING)
                        -- check to skip paddings
                        if x >= cellX and x <= cellX + effectiveCellSize and y >= cellY and y <= cellY + effectiveCellSize then
                            if grid[row][col] == "" then
                                Context.send(
                                    string.format("Your opponent played an X in the %s cell.",
                                        tostring(row) .. "," .. tostring(col)),
                                    false)
                                make_a_move(row, col)
                            end
                            return
                        end
                    end
                end
            end
        end
    end
end


function check_winner(row, col)
    -- row check
    for i = 1, GRID_SIZE do
        if grid[row][i] ~= currentPlayer then
            break
        end
        if i == GRID_SIZE then
            return true
        end
    end

    -- column check
    for i = 1, GRID_SIZE do
        if grid[i][col] ~= currentPlayer then
            break
        end
        if i == GRID_SIZE then
            return true
        end
    end

    -- main diag check
    if row == col then
        for i = 1, GRID_SIZE do
            if grid[i][i] ~= currentPlayer then
                break
            end
            if i == GRID_SIZE then
                return true
            end
        end
    end

    -- secondary diag check
    if row + col == GRID_SIZE + 1 then
        for i = 1, GRID_SIZE do
            if grid[i][GRID_SIZE - i + 1] ~= currentPlayer then
                break
            end
            if i == GRID_SIZE then
                return true
            end
        end
    end

    return false
end

function make_a_move(row, col)
    grid[row][col] = currentPlayer
    cells_left = cells_left - 1;
    if check_winner(row, col) then
        winner = currentPlayer
        print(currentPlayer .. " won!")
        if currentPlayer == "O" then
            Context.send("You won. Congratulations.", false)
            SFX.loss:play();
        else
            Context.send("You lost. Better luck next time.", false)
            SFX.win:play();
        end
    else
        if cells_left == 0 then
            print("A draw!")
            Context.send("A draw! Nobody won.", false)
            SFX.draw:play();
            return
        end
        switch_player()
    end
end

function switch_player()
    currentPlayer = (currentPlayer == "X") and "O" or "X"
    if currentPlayer == "O" then
        local actionWindow = ActionWindow:new()
        actionWindow:set_force(0.0, "It is your turn. Please place an O.", "", false, ActionsForce.Priority.LOW)
        actionWindow:add_action(PlayOAction:new(actionWindow, { grid = grid, make_a_move = make_a_move }))
        actionWindow:register()
    end
end

function is_grid_full()
    for i = 1, GRID_SIZE do
        for j = 1, GRID_SIZE do
            if grid[i][j] == "" then
                return false
            end
        end
    end
    return true
end

function reset_game()
    GameHooks.quit()
    winner = nil
    cells_left = 9
    currentPlayer = "X"
    initialize_grid()
end

function initialize_grid()
    for i = 1, GRID_SIZE do
        grid[i] = {}
        for j = 1, GRID_SIZE do
            grid[i][j] = ""
        end
    end
    Context.send("A new Tic Tac Toe game has started. You are playing as O.", true)
end

function get_effective_cell_size()
    local reserved_space = math.min(windowHeight / 2, MAX_GRID_SIZE)
    local current_grid = (math.min(windowWidth, windowHeight - reserved_space) - CELL_PADDING * (GRID_SIZE - 1)) /
        GRID_SIZE
    local maximum_grid = MAX_GRID_SIZE / GRID_SIZE
    return math.min(current_grid, maximum_grid);
end
