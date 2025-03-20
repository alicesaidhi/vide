local flags = require "./flags"
local graph = require "./graph"
type Node<T> = graph.Node<T>
type SourceNode<T> = graph.SourceNode<T>
local create_reactive_node = graph.create_reactive_node
local create_stable_node = graph.create_stable_node
local create_source_node = graph.create_source_node
local assert_stable_parent = graph.assert_stable_parent
local update_source_node = graph.update_source_node
local evaluate_node = graph.evaluate_node
local push_dependency = graph.push_dependency
local destroy = graph.destroy
local run_as = graph.run_as
local run_as_unsafe = graph.run_as_unsafe

type Map<K, V> = { [K]: V }

local function check_primitives(t: { [any]: any })
    if not flags.strict then return end

    for _, v in t do
        if type(v) == "table" or type(v) == "userdata" or type(v) == "function" then continue end
        error("table source map cannot return primitives", 0)
    end
end

local function indexes<K, VI, VO>(input: () -> Map<K, VI>, transform: (() -> VI, K) -> VO): () -> { VO }
    local owner = assert_stable_parent()
    local subowner = create_stable_node(owner)

    local input_cache = {} :: Map<K, VI?>
    local output_cache = {} :: Map<K, VO>
    local input_nodes = {} :: Map<K, SourceNode<VI>>
    local remove_queue = {} :: { K }
    local scopes = {} :: Map<K, Node<unknown>>

    local function update(data)
        for i, v in data do
            local cv = input_cache[i]

            if cv ~= v then
                input_cache[i] = v

                if cv == nil then -- create new scope and run transform
                    local scope = create_stable_node(subowner :: Node<any>, false, false)
                    scopes[i] = scope :: Node<any>

                    local node = create_source_node(v)

                    local result = run_as(scope, transform, function()
                        push_dependency(node)
                        return node.cached
                    end, i)

                    if not result.ok then
                        error(result, 0)
                    end
                    
                    input_nodes[i] = node
                    output_cache[i] = result.value
                else -- update source
                    update_source_node(input_nodes[i], v)
                end
            end
        end
    end

    local function update_children(data)
        -- queue removed values
        for i in input_cache do
            if data[i] == nil then
                table.insert(remove_queue, i)
            end
        end

        -- remove queued values
        for _, i in remove_queue do
            destroy(scopes[i])

            input_cache[i] = nil
            output_cache[i] = nil
            input_nodes[i] = nil
            scopes[i] = nil
        end

        table.clear(remove_queue)

        run_as_unsafe(subowner, update, data)

        local output_array = table.create(#scopes)
        for _, v in output_cache do
            table.insert(output_array, v)
        end
        check_primitives(output_array)
        
        return output_array
    end

    local node = create_reactive_node(owner, function()
        return update_children(input())
    end, "lazy", false :: any)

    return function()
        local result = evaluate_node(node)

        if result.ok == false then
            error(result)
        else
            return result.value
        end
    end
end

local function values<K, VI, VO>(input: () -> Map<K, VI>, transform: (VI, () -> K) -> VO): () -> { VO }
    local owner  = assert_stable_parent()
    local subowner = create_stable_node(owner, false, false)
    
    local cur_input_cache_up = {} :: Map<VI, K?>
    local new_input_cache_up = {} :: Map<VI, K>
    local output_cache = {} :: Map<VI, VO>
    local input_nodes = {} :: Map<VI, SourceNode<K>>
    local scopes = {} :: Map<VI, Node<unknown>>

    local function update(data)
        local cur_input_cache, new_input_cache = cur_input_cache_up, new_input_cache_up
        for i, v in data do
            new_input_cache[v] = i

            local cv = cur_input_cache[v]
            
            if cv == nil then -- create new scope and run transform
                local scope = create_stable_node(subowner :: Node<any>)
                scopes[v] = scope :: Node<any>

                local node = create_source_node(i)
    
                local result = run_as(scope, transform, v, function()
                    push_dependency(node)
                    return node.cached
                end)

                if not result.ok then
                    error(result, 0)
                end

                input_nodes[v] = node
                output_cache[v] = result.value
            else -- update source
                if cv ~= i then
                    update_source_node(input_nodes[v], i)
                end

                cur_input_cache[v] = nil
            end
        end
    end

    local function update_children(data: Map<K, VI>)
        local cur_input_cache, new_input_cache = cur_input_cache_up, new_input_cache_up

        if flags.strict then
            local cache = {}
            for _, v in data do
                if cache[v] ~= nil then
                    error "duplicate table value detected"
                end
                cache[v] = true
            end
        end

        run_as_unsafe(subowner, update, data)

        -- remove old values
        for v in cur_input_cache do
            destroy(scopes[v])

            output_cache[v] = nil
            input_nodes[v] = nil
            scopes[v] = nil
        end

        -- update buffer cache
        table.clear(cur_input_cache)
        cur_input_cache_up, new_input_cache_up = new_input_cache, cur_input_cache

        local output_array = table.create(#scopes)
        for _, v in output_cache do
            table.insert(output_array, v)
        end
        check_primitives(output_array)

        return output_array
    end

    local node = create_reactive_node(owner, function()
        return update_children(input())
    end, false :: any)

    return function()
        local result = evaluate_node(node)

        if result.ok == false then
            error(result.err)
        else
            return result.value
        end
    end
end

return function() return indexes, values end
