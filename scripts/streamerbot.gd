extends Node

signal TTS(payload: Dictionary)

var ws: WebSocketPeer = WebSocketPeer.new()
var url: String = "ws://127.0.0.1:8080/"
var connected: bool = false

func _ready() -> void:
	var err: int = ws.connect_to_url(url)
	if err != OK:
		printerr("WebSocket connection failed to initialize.")
		set_process(false)

func _process(_delta: float) -> void:
	ws.poll()
	var state: int = ws.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		if not connected:
			connected = true
			_subscribe_to_events()
			
		while ws.get_available_packet_count():
			var packet: PackedByteArray = ws.get_packet()
			var message: String = packet.get_string_from_utf8()
			_parse_message(message)
			
	elif state == WebSocketPeer.STATE_CLOSED:
		connected = false
		printerr("WebSocket closed: ", ws.get_close_code())
		set_process(false)

func _subscribe_to_events() -> void:
	var payload: Dictionary = {
		"request": "Subscribe",
		"id": "godot_client",
		"events": {
			"General": ["Custom"]
		}
	}
	ws.send_text(JSON.stringify(payload))

func _parse_message(message: String) -> void:
	print(message)
	var json: JSON = JSON.new()
	var err: int = json.parse(message)
	
	if err == OK:
		var data: Dictionary = json.get_data()
		
		if data.has("event") and data["event"].get("type") == "Custom":
			var custom_data: Dictionary = data.get("data", {})
			
			if custom_data.get("customevent") == "greaseJR" or data.get("customevent") == "greaseJR":
				TTS.emit(custom_data)
	else:
		printerr("Failed to parse JSON")
