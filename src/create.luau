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
	AccessoryDescription: AccessoryDescription,
	Accoutrement: Accoutrement,
	Accessory: Accessory,
	Hat: Hat,
	AdPortal: AdPortal,
	AdvancedDragger: AdvancedDragger,
	Animation: Animation,
	CurveAnimation: CurveAnimation,
	KeyframeSequence: KeyframeSequence,
	AnimationController: AnimationController,
	AnimationRigData: AnimationRigData,
	Animator: Animator,
	Annotation: Annotation,
	WorkspaceAnnotation: WorkspaceAnnotation,
	Atmosphere: Atmosphere,
	Attachment: Attachment,
	Bone: Bone,
	AudioAnalyzer: AudioAnalyzer,
	AudioChannelMixer: AudioChannelMixer,
	AudioChannelSplitter: AudioChannelSplitter,
	AudioChorus: AudioChorus,
	AudioCompressor: AudioCompressor,
	AudioDeviceInput: AudioDeviceInput,
	AudioDeviceOutput: AudioDeviceOutput,
	AudioDistortion: AudioDistortion,
	AudioEcho: AudioEcho,
	AudioEmitter: AudioEmitter,
	AudioEqualizer: AudioEqualizer,
	AudioFader: AudioFader,
	AudioFilter: AudioFilter,
	AudioFlanger: AudioFlanger,
	AudioLimiter: AudioLimiter,
	AudioListener: AudioListener,
	AudioPitchShifter: AudioPitchShifter,
	AudioPlayer: AudioPlayer,
	AudioReverb: AudioReverb,
	AudioSearchParams: AudioSearchParams,
	Backpack: Backpack,
	RemoteEvent: RemoteEvent,
	UnreliableRemoteEvent: UnreliableRemoteEvent,
	WrapDeformer: WrapDeformer,
	WrapLayer: WrapLayer,
	WrapTarget: WrapTarget,
	Beam: Beam,
	BindableEvent: BindableEvent,
	BindableFunction: BindableFunction,
	BodyAngularVelocity: BodyAngularVelocity,
	BodyForce: BodyForce,
	BodyGyro: BodyGyro,
	BodyPosition: BodyPosition,
	BodyThrust: BodyThrust,
	BodyVelocity: BodyVelocity,
	RocketPropulsion: RocketPropulsion,
	BodyPartDescription: BodyPartDescription,
	Breakpoint: Breakpoint,
	Camera: Camera,
	BodyColors: BodyColors,
	CharacterMesh: CharacterMesh,
	Pants: Pants,
	Shirt: Shirt,
	ShirtGraphic: ShirtGraphic,
	Skin: Skin,
	ClickDetector: ClickDetector,
	DragDetector: DragDetector,
	Clouds: Clouds,
	Configuration: Configuration,
	AlignOrientation: AlignOrientation,
	AlignPosition: AlignPosition,
	AngularVelocity: AngularVelocity,
	AnimationConstraint: AnimationConstraint,
	BallSocketConstraint: BallSocketConstraint,
	HingeConstraint: HingeConstraint,
	LineForce: LineForce,
	LinearVelocity: LinearVelocity,
	PlaneConstraint: PlaneConstraint,
	Plane: Plane,
	RigidConstraint: RigidConstraint,
	RodConstraint: RodConstraint,
	RopeConstraint: RopeConstraint,
	CylindricalConstraint: CylindricalConstraint,
	PrismaticConstraint: PrismaticConstraint,
	SpringConstraint: SpringConstraint,
	Torque: Torque,
	TorsionSpringConstraint: TorsionSpringConstraint,
	UniversalConstraint: UniversalConstraint,
	VectorForce: VectorForce,
	HumanoidController: HumanoidController,
	SkateboardController: SkateboardController,
	VehicleController: VehicleController,
	AirController: AirController,
	ClimbController: ClimbController,
	GroundController: GroundController,
	SwimController: SwimController,
	ControllerManager: ControllerManager,
	-- BlockMesh: BlockMesh,
	CylinderMesh: CylinderMesh,
	FileMesh: FileMesh,
	SpecialMesh: SpecialMesh,
	DataStoreGetOptions: DataStoreGetOptions,
	DataStoreIncrementOptions: DataStoreIncrementOptions,
	DataStoreOptions: DataStoreOptions,
	DataStoreSetOptions: DataStoreSetOptions,
	DebuggerWatch: DebuggerWatch,
	Dialog: Dialog,
	DialogChoice: DialogChoice,
	Dragger: Dragger,
	EulerRotationCurve: EulerRotationCurve,
	ExperienceInviteOptions: ExperienceInviteOptions,
	ExplorerFilter: ExplorerFilter,
	Explosion: Explosion,
	FaceControls: FaceControls,
	Decal: Decal,
	Texture: Texture,
	Hole: Hole,
	MotorFeature: MotorFeature,
	Fire: Fire,
	FloatCurve: FloatCurve,
	FlyweightService: FlyweightService,
	CSGDictionaryService: CSGDictionaryService,
	NonReplicatedCSGDictionaryService: NonReplicatedCSGDictionaryService,
	Folder: Folder,
	ForceField: ForceField,
	FunctionalTest: FunctionalTest,
	GetTextBoundsParams: GetTextBoundsParams,
	CanvasGroup: CanvasGroup,
	Frame: Frame,
	ImageButton: ImageButton,
	TextButton: TextButton,
	ImageLabel: ImageLabel,
	TextLabel: TextLabel,
	RelativeGui: RelativeGui,
	ScrollingFrame: ScrollingFrame,
	TextBox: TextBox,
	VideoFrame: VideoFrame,
	ViewportFrame: ViewportFrame,
	BillboardGui: BillboardGui,
	ScreenGui: ScreenGui,
	GuiMain: GuiMain,
	AdGui: AdGui,
	SurfaceGui: SurfaceGui,
	FloorWire: FloorWire,
	SelectionBox: SelectionBox,
	BoxHandleAdornment: BoxHandleAdornment,
	ConeHandleAdornment: ConeHandleAdornment,
	CylinderHandleAdornment: CylinderHandleAdornment,
	ImageHandleAdornment: ImageHandleAdornment,
	LineHandleAdornment: LineHandleAdornment,
	SphereHandleAdornment: SphereHandleAdornment,
	WireframeHandleAdornment: WireframeHandleAdornment,
	ParabolaAdornment: ParabolaAdornment,
	SelectionSphere: SelectionSphere,
	ArcHandles: ArcHandles,
	Handles: Handles,
	SurfaceSelection: SurfaceSelection,
	SelectionPartLasso: SelectionPartLasso,
	SelectionPointLasso: SelectionPointLasso,
	Path2D: Path2D,
	HapticEffect: HapticEffect,
	HeightmapImporterService: HeightmapImporterService,
	HiddenSurfaceRemovalAsset: HiddenSurfaceRemovalAsset,
	Highlight: Highlight,
	Humanoid: Humanoid,
	HumanoidDescription: HumanoidDescription,
	IKControl: IKControl,
	RotateP: RotateP,
	RotateV: RotateV,
	Glue: Glue,
	ManualGlue: ManualGlue,
	ManualWeld: ManualWeld,
	Motor: Motor,
	Motor6D: Motor6D,
	Rotate: Rotate,
	Snap: Snap,
	VelocityMotor: VelocityMotor,
	Weld: Weld,
	Keyframe: Keyframe,
	KeyframeMarker: KeyframeMarker,
	PointLight: PointLight,
	SpotLight: SpotLight,
	SurfaceLight: SurfaceLight,
	LocalizationTable: LocalizationTable,
	Script: Script,
	LocalScript: LocalScript,
	ModuleScript: ModuleScript,
	MarkerCurve: MarkerCurve,
	MaterialVariant: MaterialVariant,
	MemoryStoreService: MemoryStoreService,
	Message: Message,
	Hint: Hint,
	NoCollisionConstraint: NoCollisionConstraint,
	Noise: Noise,
	OperationGraph: OperationGraph,
	CornerWedgePart: CornerWedgePart,
	Part: Part,
	FlagStand: FlagStand,
	Seat: Seat,
	SkateboardPlatform: SkateboardPlatform,
	SpawnLocation: SpawnLocation,
	WedgePart: WedgePart,
	MeshPart: MeshPart,
	PartOperation: PartOperation,
	IntersectOperation: IntersectOperation,
	NegateOperation: NegateOperation,
	UnionOperation: UnionOperation,
	TrussPart: TrussPart,
	VehicleSeat: VehicleSeat,
	Model: Model,
	Actor: Actor,
	HopperBin: HopperBin,
	Tool: Tool,
	Flag: Flag,
	WorldModel: WorldModel,
	PartOperationAsset: PartOperationAsset,
	ParticleEmitter: ParticleEmitter,
	PathfindingLink: PathfindingLink,
	PathfindingModifier: PathfindingModifier,
	Player: Player,
	PluginAction: PluginAction,
	PluginCapabilities: PluginCapabilities,
	NumberPose: NumberPose,
	Pose: Pose,
	BloomEffect: BloomEffect,
	BlurEffect: BlurEffect,
	ColorCorrectionEffect: ColorCorrectionEffect,
	ColorGradingEffect: ColorGradingEffect,
	DepthOfFieldEffect: DepthOfFieldEffect,
	SunRaysEffect: SunRaysEffect,
	ProximityPrompt: ProximityPrompt,
	ProximityPromptService: ProximityPromptService,
	RTAnimationTracker: RTAnimationTracker,
	ReflectionMetadata: ReflectionMetadata,
	ReflectionMetadataCallbacks: ReflectionMetadataCallbacks,
	ReflectionMetadataClasses: ReflectionMetadataClasses,
	ReflectionMetadataEnums: ReflectionMetadataEnums,
	ReflectionMetadataEvents: ReflectionMetadataEvents,
	ReflectionMetadataFunctions: ReflectionMetadataFunctions,
	ReflectionMetadataClass: ReflectionMetadataClass,
	ReflectionMetadataEnum: ReflectionMetadataEnum,
	ReflectionMetadataEnumItem: ReflectionMetadataEnumItem,
	ReflectionMetadataMember: ReflectionMetadataMember,
	ReflectionMetadataProperties: ReflectionMetadataProperties,
	ReflectionMetadataYieldFunctions: ReflectionMetadataYieldFunctions,
	RemoteFunction: RemoteFunction,
	RenderingTest: RenderingTest,
	RotationCurve: RotationCurve,
	AtmosphereSensor: AtmosphereSensor,
	BuoyancySensor: BuoyancySensor,
	ControllerPartSensor: ControllerPartSensor,
	FluidForceSensor: FluidForceSensor,
	Sky: Sky,
	Smoke: Smoke,
	Sound: Sound,
	ChorusSoundEffect: ChorusSoundEffect,
	CompressorSoundEffect: CompressorSoundEffect,
	DistortionSoundEffect: DistortionSoundEffect,
	EchoSoundEffect: EchoSoundEffect,
	EqualizerSoundEffect: EqualizerSoundEffect,
	FlangeSoundEffect: FlangeSoundEffect,
	PitchShiftSoundEffect: PitchShiftSoundEffect,
	ReverbSoundEffect: ReverbSoundEffect,
	TremoloSoundEffect: TremoloSoundEffect,
	SoundGroup: SoundGroup,
	Sparkles: Sparkles,
	StandalonePluginScripts: StandalonePluginScripts,
	StarterGear: StarterGear,
	StudioAttachment: StudioAttachment,
	StudioCallout: StudioCallout,
	StyleRule: StyleRule,
	StyleSheet: StyleSheet,
	StyleDerive: StyleDerive,
	StyleLink: StyleLink,
	SurfaceAppearance: SurfaceAppearance,
	Team: Team,
	TeleportOptions: TeleportOptions,
	TerrainDetail: TerrainDetail,
	TerrainRegion: TerrainRegion,
	TestService: TestService,
	TextChannel: TextChannel,
	TextChatCommand: TextChatCommand,
	TextChatMessageProperties: TextChatMessageProperties,
	BubbleChatMessageProperties: BubbleChatMessageProperties,
	TrackerStreamAnimation: TrackerStreamAnimation,
	Trail: Trail,
	Tween: Tween,
	UIAspectRatioConstraint: UIAspectRatioConstraint,
	UISizeConstraint: UISizeConstraint,
	UITextSizeConstraint: UITextSizeConstraint,
	UICorner: UICorner,
	UIDragDetector: UIDragDetector,
	UIFlexItem: UIFlexItem,
	UIGradient: UIGradient,
	UIGridLayout: UIGridLayout,
	UIListLayout: UIListLayout,
	UIPageLayout: UIPageLayout,
	UITableLayout: UITableLayout,
	UIPadding: UIPadding,
	UIScale: UIScale,
	UIStroke: UIStroke,
	BinaryStringValue: BinaryStringValue,
	BoolValue: BoolValue,
	BrickColorValue: BrickColorValue,
	CFrameValue: CFrameValue,
	Color3Value: Color3Value,
	DoubleConstrainedValue: DoubleConstrainedValue,
	IntConstrainedValue: IntConstrainedValue,
	IntValue: IntValue,
	NumberValue: NumberValue,
	ObjectValue: ObjectValue,
	RayValue: RayValue,
	StringValue: StringValue,
	Vector3Value: Vector3Value,
	Vector3Curve: Vector3Curve,
	VideoDeviceInput: VideoDeviceInput,
	VideoPlayer: VideoPlayer,
	VirtualInputManager: VirtualInputManager,
	VisualizationMode: VisualizationMode,
	VisualizationModeCategory: VisualizationModeCategory,
	WeldConstraint: WeldConstraint,
	Wire: Wire,
}

type function getvideproperties(instancename, instances, instancetype)
	local instance
	if instancename:is("string") or instancename:is("generic") then return types.never end

	for key, value in instances:properties() do
		if key:value() == instancename:value() then
			instance = value.read
		end
	end


	if instance == types.never then return types.never end
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
				local connect_fn = is_a_signal
				local params = connect_fn:parameters()
				table.remove(params.head, 1)

				local type = types.unionof(
					nil_type,
					types.newfunction(params)
				)

				properties[key] = { read = type }
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

		if object:readparent() == nil then return end
		insert(object:readparent())
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
	print(instancename.tag)
	if instancename:is("string") or instancename:is("generic") then return types.never end

	print(instancename:value())
	for key, value in instances:properties() do
		if key:value() == instancename:value() then
			print(key)
			return value.read
		end
	end

	return types.never
end

local c = (create :: any) ::
	<T>(keyof<Instances> & T) -> (getvideproperties<T, Instances, Instance>) -> getvideinstance<T, Instances, Instance>

return c
