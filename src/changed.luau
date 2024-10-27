if not game then script = require "test/relative-string" end

local action = require(script.Parent.action)()
local cleanup = require(script.Parent.cleanup)

local function snake_case_to_pascal(str: string)
    return (string.gsub(string.gsub(str, "^(.)", string.upper), "_(.)", string.upper))
end

local function changed<T>(property: string, callback: (T) -> ())
    property = snake_case_to_pascal(property)
    return action(function(instance)
        local con = instance:GetPropertyChangedSignal(property):Connect(function()
            callback((instance :: any)[property])
        end)

        cleanup(function()
            con:Disconnect()
        end)

        callback((instance :: any)[property])
    end)
end

return changed
