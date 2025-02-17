local version = { major = 0, minor = 3, patch = 1 }

local root = require "./root"
local mount = require "./mount"
local create = require "./create"
local apply = require "./apply"
local source = require "./source"
local effect = require "./effect"
local derive = require "./derive"
local cleanup = require "./cleanup"
local untrack = require "./untrack"
local read = require "./read"
local batch = require "./batch"
local context = require "./context"
local switch = require "./switch"
local show = require "./show"
local indexes, values = require "./maps"()
local spring, update_springs = require "./spring"()
local action = require "./action"()
local changed = require "./changed"
local flags = require "./flags"

export type Source<T> = source.Source<T>
export type source<T> = Source<T>
export type Context<T> = context.Context<T>
export type context<T> = Context<T>
export type function getvideproperties(instance, instancetype)
	local properties = {}
	local nil_type = types.singleton(nil)

	local function is_signal(value: type)
		if not (value:is("class") or value:is("table")) then
			return false
		end

		for key, value in value:properties() do
			if key:value() == "Connect" and value.read.tag == "function" then
				return value.read
			end
		end

		return false
	end

	local function insert(object)
        if object:is("class") == false then return end
		if object:parent() == nil then return end
		for key, value in object:properties() do
			local is_a_signal = is_signal(value.read)
			if is_a_signal and value.read:is("table") then -- luau-lsp
				local connect_fn = is_a_signal
				local params = connect_fn:parameters()
				table.remove(params.head, 1)
	
				local type = types.unionof(
					nil_type,
					types.newfunction(params)
				)
	
				properties[key] = { read = type }
			elseif is_a_signal and value.read:is("class") then -- roblox-studio
	
			elseif value.read:is("function") or value.read:is("intersection") then
				continue
			elseif value.write then

				local value = value.write
	
				local type = types.unionof(
					types.newfunction({}, { head = { value } }),
					value,
					nil_type
				)
	
				properties[key] = { read = type }
			end
		end

		insert(object:parent())
	end
	insert(instance)

	local vide_props = types.newtable(properties)
	local vide_action = types.newtable({
		[types.singleton "priority"] = { read = types.number },
		[types.singleton "callback"] = { read = types.newfunction({ head = { instancetype } }) }
	})

	local function_returns_child = types.newfunction()
	local nested_table_or_function_or_child = types.newtable()
	local union = types.unionof( instancetype, function_returns_child, nested_table_or_function_or_child )

	nested_table_or_function_or_child:setindexer(types.number, union)
	function_returns_child:setreturns({ union })

	vide_props:setindexer(
		types.number,
		types.unionof(
			vide_action,
			instancetype,
			function_returns_child,
			vide_props,
			nil_type
		)
	)

	return vide_props
end

local function step(dt: number)
    if game then
        debug.profilebegin("VIDE STEP")
        debug.profilebegin("VIDE SPRING")
    end

    update_springs(dt)

    if game then
        debug.profileend()
        debug.profileend()
    end
end

local stepped = game and game:GetService("RunService").Heartbeat:Connect(function(dt: number)
    task.defer(step, dt)
end)

local vide = {
    version = version,

    -- core
    root = root,
    mount = mount,
    create = create,
    source = source,
    effect = effect,
    derive = derive,
    switch = switch,
    show = show,
    indexes = indexes,
    values = values,

    -- util
    cleanup = cleanup,
    untrack = untrack,
    read = read,
    batch = batch,
    context = context,

    -- animations
    spring = spring,

    -- actions
    action = action,
    changed = changed,

    -- flags
    strict = (nil :: any) :: boolean,
    defer_nested_properties = (nil :: any) :: boolean,

    -- temporary
    apply = function<T>(instance: T & Instance)
        return function(props: getvideproperties<T, Instance>)
            apply(instance, props)
            return instance
        end
    end,

    -- runtime
    step = function(dt: number)
        if stepped then
            stepped:Disconnect()
            stepped = nil
        end
        step(dt)
    end
}

setmetatable(vide :: any, {
    __index = function<T>(_, index: keyof<typeof(flags)>): index<typeof(flags), T>
        if flags[index] == nil then
            error(`{tostring(index)} is not a valid member of vide`, 0)
        else
            return flags[index]
        end
    end,

    __newindex = function<T>(_, index: T & keyof<typeof(flags)>, value: index<typeof(flags), T>)
        if flags[index] == nil then
            error(`{tostring(index)} is not a valid member of vide, 0`)
        else
            flags[index] = value
        end
    end
})

return vide
