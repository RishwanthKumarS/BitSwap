extends Area2D

@export var fps: float = 4.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")

var _timer: float = 0.0
var _showing_frame_1: bool = false


func _process(delta: float) -> void:
	if not sprite or fps <= 0.0:
		return

	_timer += delta
	var frame_duration := 1.0 / fps
	while _timer >= frame_duration:
		_timer -= frame_duration
		_showing_frame_1 = not _showing_frame_1
		sprite.frame = 1 if _showing_frame_1 else 0
