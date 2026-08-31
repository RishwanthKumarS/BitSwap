extends Camera2D
class_name PlayerCamera
## Drop this into each level scene (or make it persistent). It smoothly
## glides to whichever player is currently active, including right after
## a swap, so the camera pan itself sells the "switching control" feel.

@export var horizontal_follow_speed: float = 6.0   # higher = snappier
@export var vertical_follow_speed: float = 7.5     # kept faster so falls aren't lost off-screen
@export var snap_on_ready: bool = true
@export var vertical_offset: float = -40.0  # negative = frame upward from player center

## Shifts the camera further in the direction the player is currently
## falling/jumping, scaled by how fast they're moving, so hazards below
## (or above) become visible before the player reaches them.
@export var look_ahead_factor: float = 0.1
@export var max_look_ahead: float = 45.0


func _ready() -> void:
	if snap_on_ready:
		_snap_to_active()


func _physics_process(delta: float) -> void:
	var target: Player = PlayerManager.get_active_player()
	if not target:
		return

	var look_ahead_y: float = clamp(target.velocity.y * look_ahead_factor, -max_look_ahead, max_look_ahead)
	var target_pos := target.global_position + Vector2(0, vertical_offset + look_ahead_y)

	# Exponential smoothing — frame-rate independent. Vertical uses its own
	# (faster) speed so the camera doesn't lag behind falls, which is what
	# was causing hazards below to scroll offscreen before the player
	# reached them.
	global_position.x = lerp(
		global_position.x,
		target_pos.x,
		1.0 - exp(-horizontal_follow_speed * delta)
	)
	global_position.y = lerp(
		global_position.y,
		target_pos.y,
		1.0 - exp(-vertical_follow_speed * delta)
	)


func _snap_to_active() -> void:
	var target: Player = PlayerManager.get_active_player()
	if target:
		global_position = target.global_position + Vector2(0, vertical_offset)
