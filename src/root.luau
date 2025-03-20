local graph = require "./graph"
type Node<T> = graph.Node<T>
local create_stable_node = graph.create_stable_node
local run_as = graph.run_as
local get_scope = graph.get_scope
local destroy = graph.destroy

local refs = {}

local function root<T>(fn: (destroy: () -> ()) -> T): (() -> (), T)
    local node = create_stable_node(get_scope())

    refs[node] = true -- prevent gc of root node

    local destroy = function()
        if not refs[node] then error "root already destroyed" end
        refs[node] = nil
        destroy(node)
    end :: () -> ()

    local results = {}
    local result = run_as(node, function(destroy)
        results = { fn(destroy) } 
    end, destroy)
    if result.ok == false then
        destroy()
        error(`error while running root():\n\n{result}`, 0)
    end

    return destroy, unpack(results)
end

return root :: <T...>(fn: (destroy: () -> ()) -> T...) -> (() -> (), T...)
