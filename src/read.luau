type function CastIntoValue(value)
    if value:is("function") then
        local values = value:returns()
        local head = values.head
        local tail = values.tail

        if head then
            local first = head[1]
            return first
        elseif tail then
            return tail
        else
            error("function does not return any value")
        end
    else
        return value
    end
end

local function read<T>(value: T): CastIntoValue<T>
    return if type(value) == "function" then (value :: () -> T)() else value
end

return read
