local graph = require "./graph"
type Node<T> = graph.Node<T>
local create_stable_node = graph.create_stable_node
local get_scope = graph.get_scope
local run_as = graph.run_as

export type Context<T> = (() -> T) & (<U>(T, () -> U) -> U)

local nil_symbol = newproxy()
local count = 0

local function context<T>(...: T): Context<T>
    count += 1
    local id = count

    local has_default = select("#", ...) > 0
    local default_value = ...
    local context: { [Node<any>]: T } = {}

    return function<T>(...): any -- todo: fix type error
        local scope: Node<unknown>? | false = get_scope()

        if select("#", ...) == 0 then -- get
            while scope do
                assert(scope)
                local actal_scope: Node<unknown> = scope
                local value = context[actal_scope]
    
                if not value then
                    scope = actal_scope.parent
                    continue
                end

                if value == nil then
                    scope = actal_scope.parent
                    continue
                end
                
                return (if value ~= nil_symbol then value else nil) :: T
            end

            if has_default then
                return default_value
            else
                error("attempt to get context when no context is set and no default context is set", 0)
            end
        else -- set
            if not scope then return error("attempt to set context outside of a vide scope", 0) end

            local value, component = ...
            
            local new_scope = create_stable_node(scope, false, false)
            context[new_scope] = if value == nil then nil_symbol else value

            local function efn(err: string) return debug.traceback(err, 3) end
            local result = run_as(new_scope, component, efn)

            if not result.ok then
                error(`error while running context:\n\n{result}`, 0)
            end

            print(result.value)
            return result.value
        end

        return nil :: any
    end
end

return context
