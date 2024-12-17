require("neuro_game_sdk.utils.table_utils")
local JSON = require("neuro_game_sdk.third_party.json")


local JsonUtils = {}

function wrap_schema(schema, add_required)
    if add_required == nil then
        add_required = true
    end
    if add_required then
        return {
            type = "object",
            properties = schema,
            required = table.get_keys(schema)
        }
    else
        return {
            type = "object",
            properties = schema
        }
    end
end

JsonUtils.wrap_schema = wrap_schema

return JsonUtils
