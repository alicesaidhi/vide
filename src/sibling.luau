local graph = require "./graph"
type Node<T> = graph.Node<T>
local create_node = graph.create_node
local push_scope = graph.push_scope
local pop_scope = graph.pop_scope
local get_scope = graph.get_scope
local destroy = graph.destroy

local refs = {}

local function sibling<T...>(fn: (destroy: () -> ()) -> T...): (() -> (), T...)
    local scope = get_scope()
    local node = create_node(scope or false :: false, false, false)

    refs[node] = true -- prevent gc of root node

    local destroy = function()
        if not refs[node] then error "root already destroyed" end
        refs[node] = nil
        destroy(node)
    end :: () -> ()

    push_scope(node)

    local result = { xpcall(fn, debug.traceback, destroy) }

    pop_scope()

    if not result[1] then
        destroy()
        error(`error while running root():\n\n{result[2]}`, 0)
    end

    return destroy, unpack(result :: any, 2)
end

return sibling :: <T...>(fn: (destroy: () -> ()) -> T...) -> (() -> (), T...)
