extends Node

signal level_loading(level_path: String)
signal level_loaded(level_path: String)
signal levels_progress_changed

@export var levels: Array[String] = [
	"res://levels/level_01.tscn",
	"res://levels/level_02.tscn",
	"res://levels/level_03.tscn",
	"res://levels/level_04.tscn",
	"res://levels/level_05.tscn",
	"res://levels/level_06.tscn",
]

@export var level_select_scene: String = "res://levels/level_select/level_select.tscn"
@export var game_complete_scene: String = "res://levels/game_complete/game_complete.tscn"

const SAVE_PATH := "user://progress.cfg"

var current_level_index: int = -1
var completed_levels: Array[bool] = []


func _ready() -> void:
	completed_levels.resize(levels.size())
	completed_levels.fill(false)
	_load_progress()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_level"):
		restart_level()


func is_level_unlocked(index: int) -> bool:
	if index == 0:
		return true
	if index < 0 or index >= levels.size():
		return false
	return completed_levels[index - 1]


func is_level_completed(index: int) -> bool:
	return index >= 0 and index < completed_levels.size() and completed_levels[index]


func mark_current_level_completed() -> void:
	if current_level_index >= 0 and current_level_index < completed_levels.size():
		if not completed_levels[current_level_index]:
			completed_levels[current_level_index] = true
			_save_progress()
		levels_progress_changed.emit()


func load_level_by_index(index: int) -> void:
	if index < 0 or index >= levels.size():
		push_warning("LevelManager: level index out of range: %d" % index)
		return
	if not is_level_unlocked(index):
		push_warning("LevelManager: level %d is locked" % index)
		return
	current_level_index = index
	_change_scene(levels[index])


func next_level() -> void:
	mark_current_level_completed()
	if current_level_index + 1 < levels.size():
		load_level_by_index(current_level_index + 1)
	else:
		_change_scene(game_complete_scene)


func restart_level() -> void:
	if current_level_index != -1:
		_change_scene(levels[current_level_index])


func load_level_select() -> void:
	_change_scene(level_select_scene)


func _change_scene(path: String) -> void:
	PlayerManager.reset()
	level_loading.emit(path)
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("LevelManager: failed to load '%s' (error code %d)" % [path, err])
		return
	level_loaded.emit(path)


func _save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "completed_levels", completed_levels)
	cfg.save(SAVE_PATH)


func _load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		var saved: Array = cfg.get_value("progress", "completed_levels", [])
		for i in min(saved.size(), completed_levels.size()):
			completed_levels[i] = saved[i]
