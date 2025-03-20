local graph = require "./graph"
type Node<T> = graph.Node<T>
local create_source_node = graph.create_source_node
local push_dependency = graph.push_dependency
local update_source_node = graph.update_source_node

export type Source<T> = (() -> T) & ((value: T) -> T)

local function source<T>(initial_value: T): Source<T>
    local node = create_source_node(initial_value)

    local function update_source(...): T
        if select("#", ...) == 0 then -- no args were given
            push_dependency(node)
            return node.cached
        end

        local v = ... :: T

        update_source_node(node, v)
        return v
    end

    return update_source
end

return source :: (<T>(initial_value: T) -> Source<T>) & (<T>() -> Source<T>)
