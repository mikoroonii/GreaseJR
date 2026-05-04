extends Node

const CONFIG_NAME: String = "settings.cfg"
const SECTION_API: String = "API"
const SECTION_VOICE: String = "Voice"
const SECTION_MISC: String = "MISC"
const SECTION_AUDIO: String = "Audio"
const SECTION_ANIMATION: String = "Animation"

var config: ConfigFile = ConfigFile.new()
var config_path: String = ""

func _ready() -> void:
	_determine_config_path()
	_load_or_create_config()

func _determine_config_path() -> void:
	if OS.has_feature("editor"):
		config_path = ProjectSettings.globalize_path("res://").path_join(CONFIG_NAME)
	else:
		config_path = OS.get_executable_path().get_base_dir().path_join(CONFIG_NAME)

func _load_or_create_config() -> void:
	var err: int = config.load(config_path)
	if err != OK or not config.has_section(SECTION_VOICE):
		_create_default_config()

func _create_default_config() -> void:
	config.set_value(SECTION_API, "api_key", "")
	
	config.set_value(SECTION_VOICE, "ttsCharacterLimit", 900)
	config.set_value(SECTION_VOICE, "type", "elevenlabs")
	config.set_value(SECTION_VOICE, "voiceId", "")
	config.set_value(SECTION_VOICE, "volume", 0.35)
	config.set_value(SECTION_VOICE, "modelId", "")
	config.set_value(SECTION_VOICE, "useDialogueMode", true)
	
	config.set_value(SECTION_MISC, "model", 0)
	config.set_value(SECTION_MISC, "ui_enabled", true)
	
	config.set_value(SECTION_AUDIO, "mic_mode", false)
	config.set_value(SECTION_AUDIO, "mic", "")
	
	config.set_value(SECTION_ANIMATION, "mouth_threshold", -25)
	config.set_value(SECTION_ANIMATION, "pose_threshold", -25)
	config.set_value(SECTION_ANIMATION, "mouthshape_delay", 0.2)
	config.set_value(SECTION_ANIMATION, "pose_cooldown", 0.5)
	
	config.save(config_path)

func get_setting(section: String, key: String, default: Variant = null) -> Variant:
	return config.get_value(section, key, default)

func set_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	if config.save(config_path) != OK:
		print("Failed to save config")

func get_section_dict(section: String) -> Dictionary:
	var dict: Dictionary = {}
	if config.has_section(section):
		for key: String in config.get_section_keys(section):
			dict[key] = config.get_value(section, key)
	return dict
