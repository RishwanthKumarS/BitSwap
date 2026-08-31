extends Area2D
class_name PressureButton
## A floor button that's "pressed" for as long as at least one player
## (active or frozen — either counts as weight on it) overlaps it, and
## "released" the instant nothing is standing on it anymore.
## Set `required_player_id` to restrict it to only Player 1 or Player 2 —
## leave it on "Any Player" for a button either character can trigger.
## Attach to an Area2D with a CollisionShape2D sized to the button's plate.

signal activated
signal deactivated

@export_enum("Any Player:0", "Player 1:1", "Player 2:2") var required_player_id: int = 0

var is_pressed: bool = false
var _bodies_on_button: Array[Node] = []

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@export var unpressed_frame: int = 0
@export var pressed_frame: int = 1   # ignored if sprite has no such frame


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body is Player and _accepts_player(body) and not _bodies_on_button.has(body):
		_bodies_on_button.append(body)
		_update_pressed_state()


func _on_body_exited(body: Node) -> void:
	if _bodies_on_button.has(body):
		_bodies_on_button.erase(body)
		_update_pressed_state()


func _accepts_player(body: Player) -> bool:
	return required_player_id == 0 or body.player_id == required_player_id


func _update_pressed_state() -> void:
	var should_be_pressed := _bodies_on_button.size() > 0
	if should_be_pressed == is_pressed:
		return
	is_pressed = should_be_pressed

	if sprite:
		sprite.frame = pressed_frame if is_pressed else unpressed_frame

	if is_pressed:
		activated.emit()
	else:
		deactivated.emit()
