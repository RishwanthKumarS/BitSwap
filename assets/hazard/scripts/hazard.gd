extends Area2D
class_name Hazard

## Touching it as either player (active or frozen) restarts the level.

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		SfxManager.play("death")
		# body_entered fires during the physics step; deferring avoids the
		# "removing a CollisionObject during a physics callback" error when
		# the level scene gets torn down mid-collision-check.
		LevelManager.call_deferred("restart_level")
