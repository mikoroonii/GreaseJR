extends Node3D

@export_category("Animation")
@export var mouthshape_delay: float = 0.02
@export var animate_mouth: bool = false:
	set(v):
		if animate_mouth != v:
			animate_mouth = v
			if is_node_ready() and not animate_mouth:
				reset_mouth_shapes()

@export var pose_cooldown: float = 1.5

@onready var mesh_instance: MeshInstance3D = $emotigrease/Emoti/Skeleton3D/Emotiguy_16450_Shape_001
@onready var anim_player_emoti: AnimationPlayer = $emotigrease/AnimationPlayer
@onready var anim_player_root: AnimationPlayer = $AnimationPlayer
@onready var settings: Control = $UI.get_node("Settings")
@onready var eleven_labs: Node = %ElevenLabs
@onready var eleven_labs_audio: AudioStreamPlayer = $ElevenLabs/AudioStreamPlayer
@onready var hair: Node3D = $emotigrease/Emoti/Skeleton3D/hair

@onready var audio_in: int = 1

var reset_timer: float = 0.0
var head_reset_delay: float = 2.0

var current_mouth_shape: String = ""
var current_head_shape: String = ""

var mouth_shapes: Array[String] = [
	"head__PurseLips", "head__PartLips", "head__PuckerLips", "head__PuckerLipsOO",
	"head__PuckerLipsOOO", "head__PuckerLipsWide", "head__Grin", "head__MouthF",
	"head__MouthO", "head__MouthTH", "head__StretchLips", "head__MouthSpeak",
	"head__MouthYell"
]

var head_shapes: Array[String] = [
	"head__Angel", "head__Angry", "head__BaringTeeth", "head__Crying",
	"head__Confused", "head__Disappointed", "head__HaveABeer", "head__Hot",
	"head_IDontKnow", "head_Nerd", "head_Open-Mouthed", "head__Sad",
	"head__Sarcastic", "head__Sick", "head__Sleepy", "head__Smirk",
	"head__TongueOut", "head__EyesWide", "Smile", "Frown", "Crying2",
	"Disp[leased", "Pleading", "Troll", "Fish", "Shnoze"
]

var timer: float = 0.0
var pose_cooldown_timer: float = 0.0
var mouth_strength: float = 1.0
var can_transition: bool = true
var pose_threshold: float = -18.0
var mouth_threshold: float = -20.0
var current_db: float = 0.0

func _ready() -> void:
	mesh_instance.set("blend_shapes/head_Brows-UpDown_l", 1.0)
	mesh_instance.set("blend_shapes/head_Brows-UpDown_r", 1.0)
	mesh_instance.set("blend_shapes/THICC", 1.0)
	
	eleven_labs_audio.finished.connect(_on_eleven_labs_audio_finished)
	
	_on_ui_settings_updated()

func _apply_model(model: int) -> void:
	match model:
		0:
			mesh_instance.set_surface_override_material(0, load("res://assets/emotiguy/skin_normal.tres"))
			hair.hide()
			mesh_instance.set_surface_override_material(8, load("res://assets/emotiguy/transparent.tres"))
		1:
			hair.show()
			mesh_instance.set_surface_override_material(0, load("res://assets/emotiguy/skin.tres"))
		_:
			mesh_instance.set_surface_override_material(0, load("res://assets/emotiguy/skin_normal.tres"))
			hair.hide()
			mesh_instance.set_surface_override_material(8, load("res://assets/emotiguy/meatwad.tres"))

func _on_ui_settings_updated() -> void:
	mouthshape_delay = Global.get_setting("Animation", "mouthshape_delay", 0.02) as float
	pose_threshold = Global.get_setting("Animation", "pose_threshold", -18.0) as float
	mouth_threshold = Global.get_setting("Animation", "mouth_threshold", -20.0) as float
	pose_cooldown = Global.get_setting("Animation", "pose_cooldown", 0.5) as float
	
	var mic_mode: bool = Global.get_setting("Audio", "mic_mode", false) as bool
	if mic_mode:
		animate_mouth = true
		audio_in = 3
		if not anim_player_root.is_playing() or anim_player_root.current_animation != "in":
			anim_player_root.play("in")
	else:
		animate_mouth = false
		audio_in = 1
		reset_mouth_shapes()
	
	var current_model: int = Global.get_setting("MISC", "model", 0) as int
	_apply_model(current_model)

func _process(delta: float) -> void:
	current_db = AudioServer.get_bus_peak_volume_left_db(audio_in, 0)
	animate_mouth = current_db > mouth_threshold
	
	if pose_cooldown_timer > 0.0:
		pose_cooldown_timer -= delta
	
	if current_db < pose_threshold and not can_transition:
		can_transition = true
	elif current_db >= pose_threshold and can_transition and pose_cooldown_timer <= 0.0:
		can_transition = false
		pose_cooldown_timer = pose_cooldown
		new_headshape()
		new_pose()
	
	timer += delta
	if timer >= mouthshape_delay and animate_mouth:
		new_mouthshape()
		timer = 0.0
		
	if current_head_shape != "":
		reset_timer += delta
		if reset_timer >= head_reset_delay:
			reset_head_shapes()
			var anims: PackedStringArray = anim_player_emoti.get_animation_list()
			if anims.size() > 0:
				anim_player_emoti.play(anims[0])
			current_head_shape = ""
			reset_timer = 0.0

func new_pose() -> void:
	var anims: PackedStringArray = anim_player_emoti.get_animation_list()
	if anims.size() > 0:
		anim_player_emoti.play(anims[randi() % anims.size()])

func new_headshape() -> void:
	reset_head_shapes()
	current_head_shape = _get_random_shape(head_shapes, current_head_shape)
	mesh_instance.set("blend_shapes/" + current_head_shape, 1.0)

func new_mouthshape() -> void:
	reset_mouth_shapes()
	current_mouth_shape = _get_random_shape(mouth_shapes, current_mouth_shape)
	mesh_instance.set("blend_shapes/" + current_mouth_shape, mouth_strength)

func _get_random_shape(shapes: Array[String], current: String) -> String:
	var temp_array: Array[String] = shapes.duplicate()
	temp_array.erase(current)
	return temp_array.pick_random()

func reset_mouth_shapes() -> void:
	for shape_name: String in mouth_shapes:
		mesh_instance.set("blend_shapes/" + shape_name, 0.0)

func reset_head_shapes() -> void:
	for shape_name: String in head_shapes:
		mesh_instance.set("blend_shapes/" + shape_name, 0.0)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu"):
		settings.visible = not settings.visible

func _on_eleven_labs_pre_tts() -> void:
	if anim_player_root.current_animation != "in":
		anim_player_root.play("in")
	new_headshape()
	new_pose()

func _on_eleven_labs_audio_finished() -> void:
	await get_tree().process_frame
	
	var is_empty: bool = eleven_labs.audio_queue.is_empty() and eleven_labs.request_queue.is_empty()
	var is_working: bool = eleven_labs.is_fetching or eleven_labs.is_preparing
	
	if is_empty and not is_working:
		animate_mouth = false
		anim_player_root.play("OUT")

func _on_eleven_labs_start() -> void:
	animate_mouth = true

func _on_streamer_bot_tts(payload: Dictionary) -> void:
	if payload.has("tts"):
		eleven_labs.generate_and_play(payload["tts"], "Mac")


func _on_streamer_bot_kill_gj() -> void:
	$AnimationPlayer.play("Death")
