extends Node

@export var ui: UI

signal pre_tts
signal start

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

# --- Queue state ---
var request_queue: Array[Dictionary] = []
var audio_queue: Array[AudioStreamMP3] = []
var is_fetching: bool = false
var is_preparing: bool = false

func _ready() -> void:
	http_request.request_completed.connect(_on_request_completed)
	audio_player.finished.connect(_on_audio_finished)

# ── Public entry point ────────────────────────────────────────────────────────

func generate_and_play(text: String, _voice_name: String) -> void:
	ui.begin_load()
	
	var voice_data: Dictionary = Global.get_section_dict(Global.SECTION_VOICE)
	print(voice_data)
	
	var limit: int = int(voice_data.get("ttsCharacterLimit", 300))
	var final_text: String = text

	if text.length() > limit:
		ui.warn("Message too long, trimming...", false)
		final_text = text.left(limit)

	audio_player.volume_db = linear_to_db(voice_data.get("volume", 1.0))

	if voice_data.get("type", "") == "elevenlabs":
		request_queue.append({ "text": final_text, "voice_data": voice_data })
		_process_request_queue()
	else:
		printerr("Unsupported TTS type")
		ui.warn("Unsupported TTS type", true)

# ── Fetch stage ───────────────────────────────────────────────────────────────

func _process_request_queue() -> void:
	if is_fetching or request_queue.is_empty():
		return
	is_fetching = true
	var item: Dictionary = request_queue.pop_front()
	_request_elevenlabs(item["text"], item["voice_data"])

func _request_elevenlabs(text: String, voice_data: Dictionary) -> void:
	var api_key: String = Global.get_setting(Global.SECTION_API, "api_key", "")
	
	if api_key.is_empty():
		printerr("API Key missing")
		ui.warn("API Key missing", true)
		is_fetching = false
		return

	var url: String = "https://api.elevenlabs.io/v1/text-to-speech/" + voice_data.get("voiceId", "")
	var headers: PackedStringArray = [
		"Accept: audio/mpeg",
		"xi-api-key: " + api_key,
		"Content-Type: application/json"
	]
	var body: Dictionary = {
		"text": text,
		"model_id": voice_data.get("modelId", "eleven_multilingual_v2")
	}

	if http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body)) != OK:
		printerr("HTTPRequest failed to start")
		ui.warn("HTTPRequest failed to start.", true)
		is_fetching = false

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	is_fetching = false

	if response_code == 200:
		var stream := AudioStreamMP3.new()
		stream.data = body
		audio_queue.append(stream)
		ui.success_load()
		_try_play_next()
	else:
		printerr("API Error %d: %s" % [response_code, body.get_string_from_utf8()])
		ui.warn("API Error %d: %s " % [response_code, body.get_string_from_utf8()], true)

	_process_request_queue()

# ── Playback stage ────────────────────────────────────────────────────────────

func _try_play_next() -> void:
	if audio_player.playing or is_preparing or audio_queue.is_empty():
		return

	is_preparing = true
	audio_player.stream = audio_queue.pop_front()

	pre_tts.emit()
	await get_tree().create_timer(0.5).timeout
	is_preparing = false
	start.emit()
	audio_player.play()

func _on_audio_finished() -> void:
	_try_play_next()

func skip_current_message() -> void:
	if audio_player.playing:
		audio_player.stop()
	
	is_preparing = true
	
	await get_tree().create_timer(2.0).timeout
	
	if not is_inside_tree():
		return
		
	is_preparing = false
	_try_play_next()
