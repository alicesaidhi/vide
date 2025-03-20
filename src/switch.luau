local graph = require "./graph"
type Node<T> = graph.Node<T>
type SourceNode<T> = graph.SourceNode<T>
local create_reactive_node = graph.create_reactive_node
local create_stable_node = graph.create_stable_node
local evaluate_node = graph.evaluate_node
local run_as = graph.run_as
local destroy = graph.destroy
local assert_stable_parent = graph.assert_stable_parent

type Map<K, V> = { [K]: V }

local function switch<T, U>(source: () -> T): (map: Map<T, ((() -> U)?)>) -> () -> U?
    local owner = assert_stable_parent()
    return function(map)
        local last_scope: Node<false>?
        local last_component: (() -> U)?

        local function update(cached): U?
            local component = map[source()]
            if component == last_component then return cached end
            last_component = component

            if last_scope then
                destroy(last_scope)
                last_scope = nil
            end

            if component == nil then return nil end

            if type(component) ~= "function" then
                error "map must map a value to a function"
            end

            local new_scope = create_stable_node(owner)
            local result = run_as(new_scope, component)
            last_scope = new_scope :: Node<false>

            if not result.ok then error(result, 0) end

            return result.value
        end

        local node = create_reactive_node(owner, update, "lazy", nil)

        return function()
            local result = evaluate_node(node)

            return if result.ok then result.value else error(result, 0)
        end
    end
end

return switch
