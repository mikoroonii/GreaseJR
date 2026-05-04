class_name VolumeBar extends ProgressBar

@export var mic_bus_name: String = "Record"
var _bus_index: int

func _ready() -> void:
	_bus_index = AudioServer.get_bus_index(mic_bus_name)

func _process(_delta: float) -> void:
	var peak_volume: float = AudioServer.get_bus_peak_volume_left_db(_bus_index, 0)
	value = peak_volume

@export var threshold_colors: Array[Color] = [Color.RED, Color.BLUE, Color.GREEN]

func set_threshold(id: int, threshold: float) -> void:
	var value_range: float = max_value - min_value
	if value_range <= 0.0:
		return

	var percentage: float = clampf((threshold - min_value) / value_range, 0.0, 1.0)
	var line_name: String = "ThresholdLine_" + str(id)
	
	var line_color: Color = Color.WHITE
	if id >= 0 and id < threshold_colors.size():
		line_color = threshold_colors[id]
	
	var line: ColorRect = get_node_or_null(line_name) as ColorRect
	
	if line:
		line.anchor_left = percentage
		line.anchor_right = percentage
		line.color = line_color 
	else:
		line = ColorRect.new()
		line.name = line_name
		line.color = line_color
		
		line.set_anchors_preset(Control.PRESET_FULL_RECT)
		line.anchor_left = percentage
		line.anchor_right = percentage
		line.offset_left = -1.0
		line.offset_right = 1.0
		
		add_child(line)
