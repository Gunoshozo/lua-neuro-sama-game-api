function table.filter(tbl, predicate)
    local result = {}
    for _, value in ipairs(tbl) do
        if predicate(value) then
            table.insert(result, value)
        end
    end
    return result
end

function table.any(tbl, predicate)
    for _, value in ipairs(tbl) do
        if predicate(value) then
            return true
        end
    end
    return false
end

function table.map(tbl, transform)
    local result = {}
    for i, value in ipairs(tbl) do
        result[i] = transform(value)
    end
    return result
end

function table.get_keys(t)
    local keys={}
    for key,_ in pairs(t) do
      table.insert(keys, key)
    end
    return keys
  end