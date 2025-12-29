local typeof = game and typeof or require "../test/mock".typeof :: never
local Instance = game and Instance or require "../test/mock".Instance :: never

local defaults = require "./defaults"
local apply = require "./apply"
local action = require "./action"
local flags = require "./flags"

local ctor_cache = {} :: { [string]: (Props) -> Instance }

setmetatable(ctor_cache :: any, {
    __index = function(self, class)
        local function ctor(properties: Props): Instance
            local ok, instance: Instance = pcall(Instance.new, class :: any)
            if not ok then error(`invalid class name { class }`, 0) end

            if flags.defaults then
                local default: { [string]: unknown }? = defaults[class]
                if default then
                    for i, v in default do
                        (instance :: any)[i] = v
                    end
                end
            end

            return apply(instance, properties)
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
	AnimationGraphDefinition: AnimationGraphDefinition,
	CurveAnimation: CurveAnimation,
	KeyframeSequence: KeyframeSequence,
	AnimationController: AnimationController,
	AnimationNodeDefinition: AnimationNodeDefinition,
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
	AudioGate: AudioGate,
	AudioLimiter: AudioLimiter,
	AudioListener: AudioListener,
	AudioPitchShifter: AudioPitchShifter,
	AudioPlayer: AudioPlayer,
	AudioRecorder: AudioRecorder,
	AudioReverb: AudioReverb,
	AudioSearchParams: AudioSearchParams,
	AudioSpeechToText: AudioSpeechToText,
	AudioTextToSpeech: AudioTextToSpeech,
	AudioTremolo: AudioTremolo,
	AvatarAccessoryRules: AvatarAccessoryRules,
	AvatarAnimationRules: AvatarAnimationRules,
	AvatarBodyRules: AvatarBodyRules,
	AvatarClothingRules: AvatarClothingRules,
	AvatarCollisionRules: AvatarCollisionRules,
	AvatarRules: AvatarRules,
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
	BodyColors: BodyColors,
	CharacterMesh: CharacterMesh,
	Pants: Pants,
	Shirt: Shirt,
	ShirtGraphic: ShirtGraphic,
	Skin: Skin,
	ClickDetector: ClickDetector,
	DragDetector: DragDetector,
	Clouds: Clouds,
	CompositeValueCurve: CompositeValueCurve,
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
	CustomEvent: CustomEvent,
	CustomEventReceiver: CustomEventReceiver,
	CustomLog: CustomLog,
	BlockMesh: BlockMesh,
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
	VideoDisplay: VideoDisplay,
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
	PyramidHandleAdornment: PyramidHandleAdornment,
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
	HandRigDescription: HandRigDescription,
	HapticEffect: HapticEffect,
	HeightmapImporterService: HeightmapImporterService,
	HiddenSurfaceRemovalAsset: HiddenSurfaceRemovalAsset,
	Highlight: Highlight,
	Humanoid: Humanoid,
	HumanoidDescription: HumanoidDescription,
	HumanoidRigDescription: HumanoidRigDescription,
	IKControl: IKControl,
	InputAction: InputAction,
	InputBinding: InputBinding,
	InputContext: InputContext,
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
	MakeupDescription: MakeupDescription,
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
	Camera: Camera,
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
	StyleQuery: StyleQuery,
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
	TextGenerator: TextGenerator,
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
	ValueCurve: ValueCurve,
	Vector3Curve: Vector3Curve,
	VideoDeviceInput: VideoDeviceInput,
	VideoPlayer: VideoPlayer,
	VirtualInputManager: VirtualInputManager,
	VisualizationMode: VisualizationMode,
	VisualizationModeCategory: VisualizationModeCategory,
	WeldConstraint: WeldConstraint,
	Wire: Wire,
	WrapTextureTransfer: WrapTextureTransfer,
}

type instance = Instance

type Action = action.Action

type function GetInstance(class_name: type, instances: type): type
	if not class_name:is("singleton") then
		return instance
	end

	return instances:readproperty(class_name) or instance
end

-- temp arg for action, because for some reason its not added as a global automatically
export type function PropertiesFor(class_name: type): type
	local object = GetInstance(class_name, Instances)
	local head_table = {}
	local args_table = { head = head_table }
	local properties = types.newtable()
	local current = object
	local empty_table = {}

	local read_only_properties = table.freeze({
		types.singleton("RobloxLocked"),
		types.singleton("ClassName"),
		types.singleton("UniqueId"),
	})

	while current do
		for property, value in current:properties() do
			if table.find(read_only_properties, property) then
				continue
			end

			local value_read = value.read :: type
			local callback = is_signal(value_read)

			if callback then
				properties:setproperty(property :: any, types.optional(callback))
			elseif value_read.tag == "function" or value_read.tag == "intersection" then
				continue
			elseif value.write then
				head_table[1] = value_read

				properties:setproperty(
					property :: any,
					types.optional(
						types.unionof(
							types.newfunction(empty_table :: any, args_table :: any),
							value.write :: any
						)
					)
				)
			end
		end

		current = current:readparent()
	end

	local nested_table_or_function_or_child = types.newtable()
	local function_returns_child = types.newfunction()
	local union =
		types.unionof(nested_table_or_function_or_child, function_returns_child, instance, Action)

	nested_table_or_function_or_child:setindexer(types.number, union)
	function_returns_child:setreturns({ union })

	properties:setindexer(types.number, types.optional(union))

	return properties
end

local c = (create :: any) ::
	<ClassName>(keyof<Instances> | ClassName) -> ( props: PropertiesFor<ClassName> ) -> GetInstance<ClassName, Instances>

return c
