local function read<T>(value: (() -> T) | T): T
    return if type(value) == "function" then (value :: () -> T)() else value
end

return read
