class_name UI extends Control

@onready var spinner: Spinner = $SpinnerBox/Spinner
@onready var text: Label = $SpinnerBox/text

@onready var mic_dropdown: MenuButton = %DeviceMenu
@onready var mouth_threshold_slider: HSlider = %MouthAnimationThresholdSlider
@onready var mouth_threshold_label: Label = %MouthAnimationThresholdPercentage
@onready var pose_threshold_label: Label = %PoseAnimationThresholdPercentage
@onready var pose_threshold_slider: HSlider = %PoseAnimationThresholdSlider
@onready var mouthshape_delay_label: Label = %MouthshapeDelayValue
@onready var mouthshape_delay_slider: HSlider = %MouthshapeDelaySlider
@onready var mic_mode_checkbox: CheckButton = %MicModeCheckbox
@onready var mic_mode_value: Label = %MicModeValue
@onready var model_variant_label: Label = %ModelVariantLabel
@onready var model_menu: MenuButton = %ModelMenu
@onready var volume_bar: VolumeBar = %VolumeBar
@onready var pose_cooldown_time: Label = %PoseCooldownTime
@onready var pose_cooldown_slider: HSlider = %PoseCooldownSlider

signal settings_updated

var model_variants: Dictionary = {
	0: "Standard",
	1: "Greasy"
}

func _ready() -> void:
	if !Global.get_setting("MISC", "ui_enabled", true):
		$SpinnerBox.queue_free()
	
	var devices: PackedStringArray = AudioServer.get_input_device_list()
	var saved_mic_index: int = Global.get_setting("Audio", "mic", 0)
	
	for input in devices:
		mic_dropdown.get_popup().add_item(input)
	
	if saved_mic_index < devices.size():
		mic_dropdown.text = devices[saved_mic_index]
	
	var saved_model_index: int = Global.get_setting("MISC", "model", 0)
	
	for model in model_variants:
		model_menu.get_popup().add_item(model_variants[model])
	
	if saved_model_index < model_variants.size():
		model_menu.text = model_variants[saved_model_index]
	
	
	mic_dropdown.get_popup().id_pressed.connect(mic_changed)
	
	model_menu.get_popup().id_pressed.connect(model_changed)
	
	var saved_mouth: float = Global.get_setting("Animation", "mouth_threshold", -20.0)
	mouth_threshold_slider.value = saved_mouth
	mouth_threshold_update(saved_mouth)
	
	mouth_threshold_slider.value_changed.connect(mouth_threshold_update)
	mouth_threshold_slider.drag_ended.connect(mouth_threshold_commit)
	
	var saved_pose: float = Global.get_setting("Animation", "pose_threshold", -20.0)
	pose_threshold_slider.value = saved_pose
	pose_threshold_update(saved_pose)
	
	pose_threshold_slider.value_changed.connect(pose_threshold_update)
	pose_threshold_slider.drag_ended.connect(pose_threshold_commit)
	
	var saved_mouthshape: float = Global.get_setting("Animation", "mouthshape_delay", 0.5)
	mouthshape_delay_slider.value = saved_mouthshape
	mouthshape_delay_update(saved_mouthshape)
	
	mouthshape_delay_slider.value_changed.connect(mouthshape_delay_update)
	mouthshape_delay_slider.drag_ended.connect(mouthshape_delay_commit)
	
	var saved_mic_mode: bool = Global.get_setting("Audio", "mic_mode", false)
	mic_mode_checkbox.button_pressed = saved_mic_mode
	mic_mode_update(saved_mic_mode)
	
	mic_mode_checkbox.toggled.connect(mic_mode_commit)
	mic_mode_checkbox.toggled.connect(mic_mode_update)
	
	var saved_pose_cooldown: float = Global.get_setting("Animation", "pose_cooldown", 0.5)
	pose_cooldown_slider.value = saved_pose_cooldown
	pose_cooldown_update(saved_pose_cooldown)
	
	pose_cooldown_slider.value_changed.connect(pose_cooldown_update)
	pose_cooldown_slider.drag_ended.connect(pose_cooldown_commit)
	
	
func begin_load():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(spinner, "modulate", Color(1, 1, 1, 1), 0)
	spinner.status = Spinner.Status.SPINNING

func success_load():
	spinner.status = Spinner.Status.SUCCESS
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(spinner, "modulate", Color(1, 1, 1, 0), 1)
	
func warn(msg: String, error: bool = false):
	print(msg)
	if error: spinner.status = Spinner.Status.ERROR
	text.modulate = Color.RED if error else Color.ORANGE
	text.text = msg
	await get_tree().create_timer(2.0).timeout
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(text, "modulate", Color(0, 0, 0, 0), 1)
	tween.tween_property(spinner, "modulate", Color(1, 1, 1, 0), 1)

func mic_changed(i: int):
	Global.set_setting("Audio", "mic", i)
	AudioServer.input_device = AudioServer.get_input_device_list()[Global.get_setting("Audio", "mic", 0)]
	mic_dropdown.text = AudioServer.get_input_device_list()[Global.get_setting("Audio", "mic", 0)]

func model_changed(i: int):
	Global.set_setting("MISC", "model", i)
	model_menu.text = model_variants[i]
	settings_updated.emit()

func mouth_threshold_update(value: float):
	var string = "%.1f db" % value
	volume_bar.set_threshold(0, value)
	mouth_threshold_label.text = string

func pose_threshold_update(value: float):
	var string = "%.1f db" % value
	volume_bar.set_threshold(1, value)
	pose_threshold_label.text = string

func mouthshape_delay_update(value: float):
	var string = "%.2fs" % value
	mouthshape_delay_label.text = string

func mic_mode_update(value: bool):
	var string = "ON" if value else "OFF"
	mic_mode_value.text = string

func mouth_threshold_commit(_changed: bool) -> void:
	Global.set_setting("Animation", "mouth_threshold", mouth_threshold_slider.value)
	settings_updated.emit()

func pose_threshold_commit(_changed: bool) -> void:
	Global.set_setting("Animation", "pose_threshold", pose_threshold_slider.value)
	settings_updated.emit()

func mouthshape_delay_commit(_changed: bool) -> void:
	Global.set_setting("Animation", "mouthshape_delay", mouthshape_delay_slider.value)
	settings_updated.emit()

func mic_mode_commit(_changed: bool) -> void:
	Global.set_setting("Audio", "mic_mode", mic_mode_checkbox.button_pressed)
	settings_updated.emit()

func pose_cooldown_commit(_changed: bool) -> void:
	Global.set_setting("Animation", "pose_cooldown", pose_cooldown_slider.value)
	settings_updated.emit()

func pose_cooldown_update(value: float):
	var string = "%.1fs" % value
	pose_cooldown_time.text = string
