extends Control
class_name MainMenu

@export var play_button: Button
@export var level_select_button: Button
@export var quit_button: Button


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	LevelManager.load_level_by_index(0)


func _on_level_select_pressed() -> void:
	LevelManager.load_level_select()


func _on_quit_pressed() -> void:
	get_tree().quit()
