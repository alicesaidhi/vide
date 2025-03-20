export type SourceNode<T> = {
    last_evaluation: number,
    read effect: false,
    --- The value that is currently cached
    cached: T,

    --- Other nodes that depend on the result of this node
    [number]: ReactiveNode<T>
}

export type StableNode<T> = {
    --- The parent of this node.
    read parent: Node<T> | false,
    --- Describes the effect to run to compute the result of this node.
    read effect: false,
    read last_evaluation: number,
    --- The value of this node
    read cached: T,
    --- Nodes that this node owns.
    read children: { Node<T> },
    --- Cleanup functions to call when this node dies
    read cleanups: { () -> () },
}

export type ReactiveNode<T> = {
    --- The parent of this node.
    read parent: Node<T>,
    --- Describes the effect to run to compute the result of this node.
    read effect: (T) -> T,
    read evaluation: "eager" | "deferred" | "lazy" | "dead",
    last_evaluation: number,
    --- A list of the values this node depends on
    depending_on: { SourceNode<T> | ReactiveNode<T> },
    --- Describes the current state of this node.
    --- - clean: the cached result can be used immediately
    --- - dirty: you need to recompute the node
    --- - busy: the node is already being recomputed - throw an error!
    --- - dead: the node is dead
    state: "clean" | "dirty" | "busy" | "dead",
    --- The value of this node
    cached: T,
    --- Nodes that this node owns.
    read children: { Node<T> },
    --- Cleanup functions to call when this node dies
    read cleanups: { () -> () } | false,

    --- Other nodes that depend on the result of this node.
    [number]: ReactiveNode<T>
}

export type Node<T> = ReactiveNode<T> | StableNode<T>

local warn = warn or print

local processing_node: Node<unknown> | false = false
local deferred_nodes = {}
local version = 0

local function bump_version()
    --print("bump version")
    version += 1
    return version
end

type Result<OK, ERR=string> = {
    ok: true,
    value: OK
} | {
    ok: false,
    err: ERR,
    trace: string,
}

-- * Result addendum
local _result = { ok = false, value = nil, err = nil }
local _result_mt = { __tostring = function(self) 
    return `{self.err}\ntrace: {self.trace}`
end }

setmetatable(_result, _result_mt)

local function ok_result<OK>(value: OK): { ok: true, value: OK }
    -- local _result = setmetatable({}, _result_mt)
    _result.ok = true
    _result.value = value
    return _result :: any
end

local function fail_result<ERR>(value: ERR, trace: string): { ok: false, err: ERR, trace: string }
    local _result = setmetatable({}, _result_mt)
    _result.ok = false
    _result.err = value
    _result.trace = trace
    return _result :: any
end

local function get_result<OK, T...>(fn: (T...) -> OK, ...: T...): Result<OK>
    local ok, value: any = xpcall(fn, function(err: string)
        local message = string.gsub(tostring(err), "^.+:%d+:%s*", "")
        local trace = debug.traceback(nil, 2)
        return {
            message = message,
		    trace = trace
        }
    end, ...)
    if not ok then
        return fail_result(value.message, value.trace)
    else
        return ok_result(value)
    end
end
-- *

local function run_as<T, U...>(owner: Node<any> | false, fn: (U...) -> T, ...: U...): Result<T>
    local previous_processing = processing_node
    processing_node = owner
    local result = get_result(fn, ...)
    processing_node = previous_processing
    return result
end

local function run_as_unsafe<T, U...>(owner: Node<any> | false, fn: (U...) -> T, ...: U...): Result<T>
    local previous_processing = processing_node
    processing_node = owner
    local result = fn(...)
    processing_node = previous_processing
    return result
end

local function assert_stable_parent<T>(): StableNode<T>
    if not processing_node then
        error(`cannot call {debug.info(2, "n")} without a parent scope`, 2)
    elseif processing_node.effect ~= false then
        error(`cannot call {debug.info(2, "n")} while the parent scope is reactive - this might be a component. consider using untrack() while creating the components.`, 2)
    end

    return processing_node :: StableNode<T>
end

local function defer_node<T>(node: ReactiveNode<T>)
    if node.state == "dirty" then return end
    node.state = "dirty" :: any
    table.insert(deferred_nodes, node)
end

local function push_dependency<T>(node: SourceNode<T> | ReactiveNode<T>)
    if processing_node and processing_node.effect then
        if processing_node == node then error(`cannot add itself as dependency {node.effect}, {processing_node.effect}`) end
        table.insert(node, processing_node)
        table.insert(processing_node.depending_on, node)
    end
end

local function find_and_swap_pop<T>(t: { T }, v: T)
    local i = table.find(t, v) :: number
    local n = #t
    t[i] = t[n]
    t[n] = nil
end

local function flush_cleanups<T>(node: Node<T>)
    if node.cleanups then
        for _, fn in next, node.cleanups do
            local result = get_result(fn)
            if not result.ok then error(`cleanup error: {result.err}`, 0) end
        end

        table.clear(node.cleanups)
    end
end

local function remove_dependencies<T>(node: Node<T>)
    if node.effect then
        for _, dependency in node.depending_on do
            find_and_swap_pop(dependency, node)
        end
        table.clear(node.depending_on)
    end
end

local function destroy<T>(node: Node<T>)
    -- print("destroyed", node, debug.traceback())
    -- node.cached = nil
    flush_cleanups(node)
    remove_dependencies(node)
    
    for _, node: Node<T> in node.children do
        destroy(node)
    end
    table.clear(node.children)
end

local function destroy_owned<T>(node: Node<T>)
    for _, node: Node<T> in node.children do
        destroy(node)
    end
    table.clear(node.children)
end

local function is_similar(a: unknown, b: unknown): boolean
    return
        if type(a) == "table" and type(b) == "table" and not table.isfrozen(a :: any) and not table.isfrozen(b :: any) then false
        else a == b
end

local function update_node<T>(node: ReactiveNode<T>): Result<T>
    local previous_result = node.cached
    local previous_processing = processing_node

    flush_cleanups(node)
    destroy_owned(node)
    remove_dependencies(node)

    -- print("rerunning", debug.info(node.effect, "n"), previous_result, node)

    processing_node = node
    local result = get_result(node.effect, previous_result)
    processing_node = previous_processing

    if result.ok then
        node.state = "clean" :: any --fixme: typechecking bug
        push_dependency(node)

        if node.evaluation ~= "eager" and is_similar(previous_result, result.value) then
            -- print("DID NOT UPDATE BECAUSE SIMILAR AT", debug.info(node.effect, "sl"))
            return ok_result(node.cached)
        end
        -- print("UPDATE BECAUSE NOT SIMILAR AT", debug.info(node.effect, "sl"))

        node.last_evaluation = bump_version()
        node.cached = result.value

        return ok_result(node.cached)
    else
        warn(`effect error: {result}`)
        return fail_result(`effect error: {result.err}`, result.trace)
    end
end


local function is_dirty<T>(node: ReactiveNode<T>)
    local last_evaluation = node.last_evaluation

    if node.state == "clean" then
        return false
    end

    for _, dependency in node.depending_on do
        -- if a dependent was evaluated after this node was evaluated, it's dirty
        if dependency.effect and dependency.state == "dirty" then
            -- make sure the dependency isn't dirty
            update_node(dependency)
        end

        if dependency.last_evaluation > last_evaluation then
            return true
        end 
    end

    return #node.depending_on == 0
end


local function evaluate_node<T>(node: SourceNode<T> | ReactiveNode<T>): Result<T>
    if node.effect == false or node.state == "clean" then
        push_dependency(node :: SourceNode<T> | ReactiveNode<T>)

        return ok_result(node.cached)
    elseif node.state == "busy" then
        return fail_result(`this creates a recursive dependency, which can result in creating a infinite loop.`, debug.traceback(nil, 2))
    elseif node.state == "dead" then
        return ok_result(node.cached)
    elseif is_dirty(node) then
        return update_node(node)
    else
        node.state = "clean" :: any
        return ok_result(node.cached)
    end
end

local function flush_deferred_nodes()
    for _, node in deferred_nodes do
        local result = evaluate_node(node)

        if result.ok == false then warn(`deferred node error: {result}`) end
    end
    table.clear(deferred_nodes)
end

local _pending_eval: { ReactiveNode<unknown> } = {}
local function invalidate_loop<T>(node: SourceNode<T> | ReactiveNode<T>)
    if node.state == "dirty" then return end
    for _, value in ipairs(node) do
        if value.evaluation == "eager" then -- append it to a queue so it can be evaluated after all nodes are marked dirty.
            invalidate_loop(value)
            value.state = "dirty"
            table.insert(_pending_eval, value)
        elseif value.evaluation == "deferred" then
            invalidate_loop(value)
            defer_node(value)
        else
            invalidate_loop(value)
            value.state = "dirty"
        end
    end
end

local function invalidate<T>(node: SourceNode<T>)
    invalidate_loop(node)

    for _, node in _pending_eval do
            -- print("CHECKING", count(node.depending_on), "DEPENDENCIES FOR", debug.info(node.effect, "sl"))
        for _, dependent in node.depending_on do
            -- print("CHECKING", dependent.last_evaluation > node.last_evaluation, dependent.effect and `{debug.info(dependent.effect, "s")}:{debug.info(dependent.effect, "l")}`)
            run_as_unsafe(false, evaluate_node, dependent)
            -- print("checked", dependent.state, dependent.last_evaluation > node.last_evaluation, `{debug.info(dependent.effect, "s")}:{debug.info(dependent.effect, "l")}`)
        end

        -- print("EVALUATING NODE", is_dirty(node))
        run_as_unsafe(false, evaluate_node, node)
    end
    table.clear(_pending_eval)
end

local function create_reactive_node<T>(parent: StableNode<T> | false, effect: (T) -> T, evaluation: "eager" | "deferred" | "lazy", cached: T?)
    local node = {
        parent = parent,
        last_evaluation = bump_version(),
        
        effect = effect,
        evaluation = evaluation,
        state = "dirty",
        cached = cached,
        depending_on = {},

        children = {} :: { Node<T> },
        cleanups = {}
    } :: ReactiveNode<T>

    if parent then table.insert(parent.children, node) end

    if evaluation == "deferred" then
        table.insert(deferred_nodes, node)
    end

    return node
end

local function create_stable_node<T>(parent: Node<T> | false)
    local node = {
        parent = parent,
        last_evaluation = bump_version(),

        effect = false,

        children = table.create(1),
        cleanups = table.create(1)
    } :: StableNode<T>
    
    if parent then
        table.insert(parent.children, node)
    end
    
    return node
end

local function create_source_node<T>(value: T): SourceNode<T>
    local node = {
        last_evaluation = bump_version(),
        effect = false,
        cached = value
    } :: SourceNode<T>

    return node
end

local function update_source_node<T>(node: SourceNode<T>, value: T)
    if is_similar(node.cached, value) then return end
    node.last_evaluation = bump_version()
    node.cached = value
    invalidate(node)
end

local function get_scope<T>(): Node<T> | false
    return processing_node
end

local function push_cleanup<T>(scope: Node<T>, cleanup: () -> ())
    if scope.cleanups == false then
        scope.cleanups = { cleanup } :: any --fixme: type error
    else
        table.insert(scope.cleanups, cleanup)
    end
end

return {
    update_source_node = update_source_node,
    create_source_node = create_source_node,
    create_stable_node = create_stable_node,
    create_reactive_node = create_reactive_node,

    invalidate = invalidate,
    flush_deferred_nodes = flush_deferred_nodes,

    evaluate_node = evaluate_node,
    push_dependency = push_dependency,
    get_result = get_result,
    is_similar = is_similar,

    destroy_owned = destroy_owned,
    destroy = destroy,

    is_dirty = is_dirty,
    assert_stable_parent = assert_stable_parent,
    get_scope = get_scope,

    run_as = run_as,
    run_as_unsafe = run_as_unsafe,

    push_cleanup = push_cleanup,

    get_children = function<T>(node: ReactiveNode<T> | StableNode<T>)
        return { unpack(node) }
    end
}