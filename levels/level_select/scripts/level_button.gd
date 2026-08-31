extends Button
class_name LevelButton

signal level_selected(index: int)

var level_index: int = 0

@onready var lock_icon: TextureRect = get_node_or_null("LockIcon")
@onready var complete_icon: TextureRect = get_node_or_null("CompleteIcon")


func _ready() -> void:
	pressed.connect(_on_pressed)


func setup(index: int, unlocked: bool, completed: bool) -> void:
	level_index = index
	text = "Level %d" % (index + 1)
	disabled = not unlocked

	if lock_icon:
		lock_icon.visible = not unlocked
	if complete_icon:
		complete_icon.visible = completed


func _on_pressed() -> void:
	level_selected.emit(level_index)
