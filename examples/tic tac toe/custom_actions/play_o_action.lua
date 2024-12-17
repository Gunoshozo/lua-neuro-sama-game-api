local NeuroAction = require("neuro_game_sdk.actions.neuro_action")
local JsonUtils = require("neuro_game_sdk.utils.json_utils")
local ExecutionResult = require("neuro_game_sdk.websocket.execution_result")
require("neuro_game_sdk.string_consts")
require("neuro_game_sdk.utils.table_utils")

local PlayOAction = setmetatable({}, { __index = NeuroAction })
PlayOAction.__index = PlayOAction

function PlayOAction:new(actionWindow, ticTacToe)
    local obj = NeuroAction.new(self, actionWindow)
    obj._ticTacToe = ticTacToe -- {grid = grid, make_a_move = make_a_move}
    return obj
end

function PlayOAction:_get_name()
    return "play"
end

function PlayOAction:_get_description()
    return "Place an O in the specified cell."
end

function PlayOAction:_get_schema()
    return JsonUtils.wrap_schema({
        cell = {
            enum = self:_get_available_cells()
        }
    })
end

function PlayOAction:_validate_action(data, state)
    local cell = data:get_string("cell")
    if not cell then
        return ExecutionResult.failure(Strings.action_failed_missing_required_parameter("cell"))
    end

    local cells = self:_get_available_cells()
    if not table.any(cells, function(free_cell)
            return free_cell == cell
        end) then
        return ExecutionResult.failure(Strings.action_failed_invalid_parameter("cell"))
    end
    state["cell"] = cell
    return ExecutionResult.success()
end

function PlayOAction:_execute_action(state)
    local row = tonumber(string.sub(state["cell"],1,1))
    local col = tonumber(string.sub(state["cell"],3,3))
    self._ticTacToe.make_a_move(row, col)
end

function PlayOAction:_get_available_cells()
    local available_cells = {}
    local grid = self._ticTacToe.grid
    for row = 1, 3, 1 do
        for col = 1, 3, 1 do
            if grid[row][col] == "" then
                table.insert(available_cells, tostring(row) .. "," .. tostring(col))
            end
        end
    end
    return available_cells
end

return PlayOAction
