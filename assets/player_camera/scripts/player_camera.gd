extends Camera2D
class_name PlayerCamera
## Drop this into each level scene (or make it persistent). It smoothly
## glides to whichever player is currently active, including right after
## a swap, so the camera pan itself sells the "switching control" feel.

@export var follow_speed: float = 6.0     # higher = snappier
@export var snap_on_ready: bool = true


func _ready() -> void:
	if snap_on_ready:
		_snap_to_active()


func _physics_process(delta: float) -> void:
	var target: Player = PlayerManager.get_active_player()
	if target:
		global_position = global_position.lerp(
			target.global_position,
			1.0 - exp(-follow_speed * delta)
		)


func _snap_to_active() -> void:
	var target: Player = PlayerManager.get_active_player()
	if target:
		global_position = target.global_position
