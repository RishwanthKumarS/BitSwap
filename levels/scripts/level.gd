extends Node2D
class_name Level
## Attach to the root Node2D of each level scene. Expected child structure:
##
## Level (this script)
## ├── SpawnPoints
## │   ├── Player1Spawn   (Marker2D)
## │   └── Player2Spawn   (Marker2D)
## ├── Goal               (Area2D, optional)
## └── PlayerCamera       (Camera2D with player_camera.gd, optional)

@export var player1_scene: PackedScene  # e.g. Player1.tscn — has Player1's SpriteFrames
@export var player2_scene: PackedScene  # e.g. Player2.tscn — has Player2's SpriteFrames

@onready var spawn_p1: Marker2D = $SpawnPoints/Player1Spawn
@onready var spawn_p2: Marker2D = $SpawnPoints/Player2Spawn
@onready var goal: Area2D = get_node_or_null("Goal")


func _ready() -> void:
	_spawn_players()
	if goal:
		goal.body_entered.connect(_on_goal_body_entered)


func _spawn_players() -> void:
	var p1 := player1_scene.instantiate() as Player
	p1.player_id = 1
	add_child(p1)
	p1.global_position = spawn_p1.global_position

	var p2 := player2_scene.instantiate() as Player
	p2.player_id = 2
	add_child(p2)
	p2.global_position = spawn_p2.global_position


func _on_goal_body_entered(body: Node) -> void:
	if body is Player:
		# body_entered fires during the physics step, and change_scene_to_file
		# ends up freeing CollisionObject2D nodes as part of the scene swap —
		# doing that mid-physics-callback throws an engine warning/error.
		# Defer it to idle time instead.
		LevelManager.call_deferred("next_level")
