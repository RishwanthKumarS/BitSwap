extends Control
class_name LevelSelectMenu

@export var level_button_scene: PackedScene   # assign LevelButton.tscn in Inspector

@onready var button_container: Container = $ButtonContainer


func _ready() -> void:
	LevelManager.levels_progress_changed.connect(_build_buttons)
	_build_buttons()


func _build_buttons() -> void:
	for child in button_container.get_children():
		child.queue_free()

	for i in LevelManager.levels.size():
		var btn := level_button_scene.instantiate() as LevelButton
		button_container.add_child(btn)
		btn.setup(
			i,
			LevelManager.is_level_unlocked(i),
			LevelManager.is_level_completed(i)
		)
		btn.level_selected.connect(_on_level_button_pressed)


func _on_level_button_pressed(index: int) -> void:
	LevelManager.load_level_by_index(index)
