extends Node
## Autoload this as "LevelManager" (Project Settings > Autoload).
## Central place to list levels and move between them.

signal level_loading(level_path: String)
signal level_loaded(level_path: String)

@export var levels: Array[String] = [
	"res://levels/level_01.tscn",
	"res://levels/level_02.tscn",
	"res://levels/level_03.tscn",
]

@export var level_select_scene: String = "res://ui/level_select.tscn"

var current_level_index: int = -1


func load_level_by_index(index: int) -> void:
	if index < 0 or index >= levels.size():
		push_warning("LevelManager: level index out of range: %d" % index)
		return
	current_level_index = index
	_change_scene(levels[index])


func load_level_by_path(path: String) -> void:
	var idx := levels.find(path)
	if idx != -1:
		current_level_index = idx
	_change_scene(path)


func next_level() -> void:
	if current_level_index + 1 < levels.size():
		load_level_by_index(current_level_index + 1)
	else:
		print("LevelManager: reached the last level — returning to level select.")
		load_level_select()


func restart_level() -> void:
	if current_level_index != -1:
		_change_scene(levels[current_level_index])


func load_level_select() -> void:
	_change_scene(level_select_scene)


func _change_scene(path: String) -> void:
	# Clear stale player references before the new scene's players register.
	PlayerManager.reset()
	level_loading.emit(path)
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("LevelManager: failed to load '%s' (error code %d)" % [path, err])
		return
	level_loaded.emit(path)
