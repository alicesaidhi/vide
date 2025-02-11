
local Signal = {} do
    Signal.__index = Signal
    Signal.__type = "RBXScriptSignal"

    local function new_connection(signal, fn)
        return {
            signal = signal,
            fn = fn,

            Disconnect = function(self)
                local i = table.find(signal.connections, self)
                if not i then return end
                table.remove(signal.connections, i)
            end
        }
    end

    function Signal.new()
        return setmetatable({
            connections = {}
        }, Signal)
    end

    function Signal.Connect(self, fn)
        local con = new_connection(self, fn)
        table.insert(self.connections, con)
        return con
    end

    function Signal.fire(self, ...)
        for i = #self.connections,  1, -1 do
            self.connections[i].fn(...)
        end
    end
end

local Instance = {} do
    --[[

    attempt to mimic roblox engine's method of userdata reflection
    proxy can gc independantly of actual instance data
    proxy prevents gc of actual instance data
    user code never has direct access to actual instance data, only to proxy
    internal weak map kept data -> proxy
    
    ]]

    type userdata = { __USERDATA: true }

    type ProxyMT = {
        proxy: userdata,
        data: Data,
        __index: any,
        __newindex: any
    }

    type Data = {
        name: string,
        parent: Data?,
        children: { Data },
        changed: { [string]: RBXScriptSignal },
        properties: { [string]: unknown },
        changed_signal: RBXScriptSignal,
        destroying: RBXScriptSignal,
        class: string,
        type: "Instance"
    }

    local function deep_clone<T>(template: T & {}): T
        local t = table.clone(template :: {}) :: {}

        for i, v in next, t do
            if type(v) == "table" then
                t[i] = deep_clone(v)
            end
        end

        return t :: T & {}
    end

    local proxies = {} :: { [Data]: userdata? }
    setmetatable(proxies :: any, { __mode = "v" })

    local function get_data(userdata: userdata): Data
        local function f(userdata: userdata): ProxyMT
            return getmetatable(userdata :: any)
        end

        return f(userdata).data
    end

    local function is_instance(value: unknown): boolean
        local mt = getmetatable(value :: any)
        return mt and mt.data and mt.data.type == "Instance"
    end

    local methods = {}

    local function __index(userdata: userdata, property: string): ()
        local data = get_data(userdata)
        return if methods[property] then methods[property]
            elseif property == "Name" then data.name
            elseif property == "Parent" then data.parent
            elseif property == "Destroying" then data.destroying
            elseif property == "Changed" then data.changed_signal
            else data.properties[property] 
    end

    local function __newindex(userdata: userdata, property: string, value: unknown)
        local data = get_data(userdata)
        if property == "Name" then
            if type(value) ~= "string" then error("name must be a string", 2) end
            data.name = value :: string
        elseif property == "Parent" then
            assert(value == nil or is_instance(value), "attempt to set non-instance as parent")
            local parent = data.parent
            if parent then
                data.parent = nil
                table.remove(parent.children, table.find(parent.children, data))
            end
            if value then
                data.parent = get_data(value :: userdata)
                table.insert(get_data(value :: userdata).children, data)
            end
        else
            data.properties[property] = value
        end

        if data.changed[property] then
            Signal.fire(data.changed[property])
        end

        Signal.fire(data.changed_signal, property)
    end

    local function get_proxy(data: Data): userdata
        return proxies[data] or (function()
            local userdata = newproxy(true)
            local proxy = getmetatable(userdata)
            proxy.proxy = userdata
            proxy.data = data
            proxy.__index = __index
            proxy.__newindex = __newindex
            proxies[data] = userdata   
            return userdata
        end)()
    end

    local classes: {[string]: (string) -> (Data, ((Instance) -> ())?)}  = {}

    local function base(class: string)
        return {
            name = "UNNAMED",
            parent = nil,
            children = {},
            changed = {},
            properties = {},
            class = class,
            changed_signal = Signal.new() :: any,
            destroying = Signal.new() :: any,
            type = "Instance" :: "Instance"
        }
    end

    function Instance.new(class: string): Instance
        local creator = classes[class]
        if not creator then error(`No class exists with the name "{class}" {debug.traceback()}`) end
        local data, fn = creator(class)
        local proxy = get_proxy(data) :: any
        if fn then fn(proxy) end

        return proxy
    end

    function Instance.add_proxy(class: string, fn: (string) -> (Data, ((Instance) -> ())?))
        classes[class] = fn
    end

    function Instance.is_instance(value: unknown): boolean
        return is_instance(value)
    end

    function methods.Clone(userdata: userdata): userdata
        local data = get_data(userdata)
        local class = data.class
        
        local creator = classes[class]
        if not creator then error(`No class exists with the name "{class}" {debug.traceback()}`) end
        local clone_data, fn = creator(class)
        local clone_userdata = get_proxy(clone_data) :: any

        clone_data.properties = table.clone(data.properties)
        if fn then fn(clone_userdata) end

        return clone_userdata
    end

    function methods.FindFirstChild(userdata: userdata, target: string): userdata?
        local data = get_data(userdata)
        for _, child in data.children do
            if child.name == target then
                return get_proxy(child)
            end
        end
        return nil
    end

    function methods.GetChildren(userdata: userdata): { userdata }
        local children = get_data(userdata).children
        local userdatas = table.create(#children)

        for i, child in next, children do
            userdatas[i] = get_proxy(child)
        end

        return userdatas
    end

    function methods.GetPropertyChangedSignal(userdata: userdata, property: string): RBXScriptSignal
        local data = get_data(userdata)
        if not data.changed[property] then
            data.changed[property] = Signal.new() :: any
        end
        return data.changed[property]
    end

    function methods.Destroy(userdata: userdata)
        local data = get_data(userdata);
        Signal.fire(data.destroying)
        data.parent = nil
        if data.changed["Parent"] then
            Signal.fire(data.changed["Parent"])
        end
    end
end
