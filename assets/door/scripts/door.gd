extends StaticBody2D
class_name Door
## A door that slides open while its linked PressureButton(s) are pressed,
## and slides shut again the moment nothing's on the button.
##
## Expected structure:
## Door (this script, StaticBody2D)
## ├── CollisionShape2D   (blocks movement while closed)
## └── Sprite2D           (visual — swap texture per color variant via
##                          scene inheritance, e.g. DoorP1.tscn / DoorP2.tscn)

@export var buttons: Array[NodePath] = []          # PressureButton node paths that control this door
@export var require_all: bool = false               # false = ANY linked button opens it, true = ALL must be pressed
@export var open_offset: Vector2 = Vector2(0, -64)   # direction + distance the door slides when open
@export var move_time: float = 0.15

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

var _button_nodes: Array[PressureButton] = []
var _is_open: bool = false
var _closed_position: Vector2
var _tween: Tween


func _ready() -> void:
	_closed_position = position

	for path in buttons:
		var btn := get_node_or_null(path) as PressureButton
		if btn:
			_button_nodes.append(btn)
			btn.activated.connect(_on_button_state_changed)
			btn.deactivated.connect(_on_button_state_changed)
		else:
			push_warning("Door: could not find PressureButton at path %s" % path)

	_update_door_state(true)


func _on_button_state_changed() -> void:
	_update_door_state(false)


func _should_be_open() -> bool:
	if _button_nodes.is_empty():
		return false
	if require_all:
		for btn in _button_nodes:
			if not btn.is_pressed:
				return false
		return true
	else:
		for btn in _button_nodes:
			if btn.is_pressed:
				return true
		return false


func _update_door_state(instant: bool) -> void:
	var should_open := _should_be_open()
	if should_open == _is_open and not instant:
		return
	_is_open = should_open
		
	var target_pos := _closed_position + open_offset if _is_open else _closed_position

	if instant:
		position = target_pos
		if collision_shape:
			collision_shape.set_deferred("disabled", _is_open)
		return

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", target_pos, move_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if collision_shape:
		if _is_open:
			# Open immediately so nothing gets stuck mid-slide.
			collision_shape.set_deferred("disabled", true)
		else:
			# Re-enable collision only once it's fully back in place.
			_tween.finished.connect(
				func(): collision_shape.set_deferred("disabled", false),
				CONNECT_ONE_SHOT
			)
