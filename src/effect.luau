local graph = require "./graph"
local create_reactive_node = graph.create_reactive_node
local assert_stable_parent = graph.assert_stable_parent
local evaluate_node = graph.evaluate_node

local function effect<T>(callback: (T) -> T, initial_value: T)
    local node = create_reactive_node(assert_stable_parent(), callback, "eager", initial_value)

    evaluate_node(node)
end

return effect :: (<T>(callback: (T) -> T, initial_value: T) -> ()) & ((callback: () -> ()) -> ())
