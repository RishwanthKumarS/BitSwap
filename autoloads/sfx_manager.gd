extends Node
## Autoload this as "SfxManager" (Project Settings > Autoload).
## Plays one-shot sound effects from `sfx_folder` by name. Uses a small pool
## of AudioStreamPlayer nodes so overlapping sounds (e.g. two jumps in a row)
## don't cut each other off.

@export var sfx_folder: String = "res://sfx"
@export var volume_db: float = 0.0
@export var pool_size: int = 8

## Maps a sound name to its file inside sfx_folder. Edit these filenames to
## match whatever you drop into the sfx folder.
@export var sfx_files: Dictionary = {
	"death": "8-bit-death.mp3",
	"jump": "edr-8-bit-jump-001-171817.mp3",
	"level_clear": "level_clear.mp3",
	"button_press": "button_press.mp3",
	"character_swap": "character_swap.mp3",
}

var _streams: Dictionary = {}       # name -> AudioStream
var _pool: Array[AudioStreamPlayer] = []
var _next_pool_index: int = 0


func _ready() -> void:
	_load_streams()
	_build_pool()


func _load_streams() -> void:
	for sfx_name in sfx_files.keys():
		var path := sfx_folder.path_join(sfx_files[sfx_name])
		if ResourceLoader.exists(path):
			_streams[sfx_name] = load(path) as AudioStream
		else:
			push_warning("SfxManager: no file found for '%s' at %s" % [sfx_name, path])


func _build_pool() -> void:
	for i in pool_size:
		var player := AudioStreamPlayer.new()
		player.volume_db = volume_db
		add_child(player)
		_pool.append(player)


## Play a sound effect by name, e.g. SfxManager.play("jump")
func play(sfx_name: String, pitch: float = 1.0) -> void:
	if not _streams.has(sfx_name):
		push_warning("SfxManager: unknown sfx '%s'" % sfx_name)
		return

	var player := _get_free_player()
	player.stream = _streams[sfx_name]
	player.pitch_scale = pitch
	player.play()


func _get_free_player() -> AudioStreamPlayer:
	# Prefer an idle player; fall back to round-robin so we never stall.
	for player in _pool:
		if not player.playing:
			return player
	var player := _pool[_next_pool_index]
	_next_pool_index = (_next_pool_index + 1) % _pool.size()
	return player


## Convenience shortcuts so callsites read a bit nicer.
func play_death() -> void: play("death")
func play_jump() -> void: play("jump")
func play_level_clear() -> void: play("level_clear")
func play_button_press() -> void: play("button_press")
func play_character_swap() -> void: play("character_swap")


func set_sfx_volume_db(db: float) -> void:
	volume_db = db
	for player in _pool:
		player.volume_db = db
