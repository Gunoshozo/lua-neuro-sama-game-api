local IncomingData = {}
IncomingData.__index = IncomingData

function IncomingData:new(data)
    local obj = setmetatable({
        _data = data
    }, self)
    return obj
end

function IncomingData:get_string(name, default)
    default = default or ""
    local value = self._data[name]
    if type(value) ~= "string" then
        value = default
    end
    return value
end

-- get table
function IncomingData:get_object(name, default)
    default = default or {}
    local value = self._data[name] or {}
    if type(value) ~= "table" then
        value = default
    end
    return IncomingData:new(value)
end

return IncomingData