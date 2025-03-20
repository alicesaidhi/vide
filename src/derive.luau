local graph = require "./graph"
local create_reactive_node = graph.create_reactive_node
local assert_stable_parent = graph.assert_stable_parent
local evaluate_node = graph.evaluate_node

local function derive<T>(source: () -> T): () -> T
    local node = create_reactive_node(assert_stable_parent(), source, "lazy", false)

    return function()
        local result = evaluate_node(node)

        return if result.ok then result.value else error(result, 0)
    end
end

return derive
