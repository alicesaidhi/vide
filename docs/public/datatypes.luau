
local function table_to_proxy(t: any)
    local proxy = newproxy(true)
    local mt = getmetatable(proxy)

    for i, v in getmetatable(t) do
        mt[i] = v
    end

    function mt:__index(i)
        return t[i]
    end

    function mt:__newindex(i, v)
        t[i] = v
    end

    return proxy
end


local Color3 = { __type = "Color3" } do
    function Color3.new(r, g, b)
        return table_to_proxy(setmetatable({ R = r, G = g, B = b }, Color3))
    end

    function Color3.__eq(a, b)
        return a.R == b.R and a.G == b.G and a.B == b.B
    end
end

local Vector2 = { __type = "Vector2" } do
    function Vector2.new(x, y)
        return table_to_proxy(setmetatable({ X = x, Y = y }, Vector2))
    end

    function Vector2.__eq(a, b)
        return a.X == b.X and a.Y == b.Y
    end
end

local UDim2 = { __type = "UDim2" } do
    function UDim2.new(sx, ox, sy, oy)
        return table_to_proxy(setmetatable({ x = { scale = sx, offset = ox }, y = { scale = sy, offset = oy } }, UDim2))
    end

    function UDim2.fromScale(x, y)
        return table_to_proxy(setmetatable({ x = { scale = x, offset = 0 }, y = { scale = y, offset = 0 } }, UDim2))
    end

    function UDim2.__eq(a, b)
        return a.x.scale == b.x.scale and
            b.x.offset == b.x.offset and
            a.y.scale == b.y.scale and
            a.y.offset == b.y.offset
    end
end

local Enum = {} do
    setmetatable(Enum, { __index = function(self, index)
        local v = setmetatable({}, { __index = function(self, index) 
            self[index] = true
            return true
        end})
        self[index] = v
        return v
    end})
end

local typeof = function(v)
    return if Instance.is_instance(v) then "Instance"
        elseif getmetatable(v) and getmetatable(v).__type then getmetatable(v).__type
        else type(v)
end