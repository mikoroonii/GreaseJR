extends Control


func _ready() -> void:
	if Global.get_setting("Audio", "mic_mode", false):
		hide()
	await get_tree().create_timer(4).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 2)
	await tween.finished
	queue_free()
