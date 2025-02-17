local typeof = game and typeof or require "../test/mock".typeof :: never
local Instance = game and Instance or require "../test/mock".Instance :: never

local defaults = require "./defaults"
local apply = require "./apply"

local ctor_cache = {} :: { [string]: (Props) -> Instance }

setmetatable(ctor_cache :: any, {
    __index = function(self, class)
        local ok, instance: Instance = pcall(Instance.new, class :: any)
        if not ok then error(`invalid class name, could not create instance of class { class }`, 0) end

        local default: { [string]: unknown }? = defaults[class]
        if default then
            for i, v in default do
                (instance :: any)[i] = v
            end
        end

        local function ctor(properties: Props): Instance
            return apply(instance:Clone(), properties)
        end

        self[class] = ctor
        return ctor
    end
})

local function create_instance(class: string)
    return ctor_cache[class]
end

local function clone_instance(instance: Instance)
    return function(properties: Props): Instance
        local clone = instance:Clone()
        if not clone then error "attempt to clone a non-archivable instance" end
        return apply(clone, properties)
    end
end

local function create(class_or_instance: string | Instance, props: Props?): ((Props) -> Instance) | Instance
	local result: (Props) -> Instance
	if type(class_or_instance) == "string" then
		result = create_instance(class_or_instance)
	elseif typeof(class_or_instance) == "Instance" then
		result = clone_instance(class_or_instance)
	else
		error("bad argument #1, expected string or instance, got " .. typeof(class_or_instance), 0)
		return nil :: never
	end
	if props then
		return result(props)
	end
	return result
end

type Props = { [any]: any }

type Instances = {
	Folder: Folder,
	BillboardGui: BillboardGui,
	CanvasGroup: CanvasGroup,
	Frame: Frame,
	ImageButton: ImageButton,
	ImageLabel: ImageLabel,
	ScreenGui: ScreenGui,
	ScrollingFrame: ScrollingFrame,
	SurfaceGui: SurfaceGui,
	TextBox: TextBox,
	TextButton: TextButton,
	TextLabel: TextLabel,
	UIAspectRatioConstraint: UIAspectRatioConstraint,
	UICorner: UICorner,
	UIGradient: UIGradient,
	UIGridLayout: UIGridLayout,
	UIListLayout: UIListLayout,
	UIPadding: UIPadding,
	UIPageLayout: UIPageLayout,
	UIScale: UIScale,
	UISizeConstraint: UISizeConstraint,
	UIStroke: UIStroke,
	UIFlexItem: UIFlexItem,
	UITableLayout: UITableLayout,
	UITextSizeConstraint: UITextSizeConstraint,
	VideoFrame: VideoFrame,
	ViewportFrame: ViewportFrame,
	UIDragDetector: UIDragDetector,
	ProximityPrompt: ProximityPrompt,
	Part: Part,
	WorldModel: WorldModel,
	Camera: Camera,
}


type function getvideproperties(instance, instancetype)
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
	
				-- properties[key] = { read = type }
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

type function getvideinstance(instancename, instances, instancetype)
	-- assert(instancename:is("generic") == false, "received generic")
	if instancename:is("string") or instancename:is("generic") then return instancetype end

	for key, value in instances:properties() do
		if key:value() == instancename:value() then return value.read end
	end

	return instancetype
end

local c = (create :: any) ::
	<T>(keyof<Instances> & T) -> (getvideproperties<getvideinstance<T, Instances, Instance>, Instance>) -> getvideinstance<T, Instances, Instance>

return c