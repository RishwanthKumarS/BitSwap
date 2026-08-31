extends Node
## Autoload this as "MusicManager" (Project Settings > Autoload).
## Plays the tracks in `tracks` back-to-back, and loops the whole playlist
## once it reaches the end. Because this is an autoload, it lives outside
## the scene tree that gets swapped on level load/restart, so the music is
## never interrupted by LevelManager's scene changes.
##
## NOTE: tracks are listed explicitly (instead of scanning `res://music` at
## runtime with DirAccess) because in an exported build, listing a res://
## directory only returns *.gd/*.import filenames, not the real asset names
## - so a folder scan silently finds nothing outside the editor.

@export var tracks: Array[AudioStream] = []
@export var shuffle: bool = true
@export var volume_db: float = -6.0

var _player: AudioStreamPlayer
var _playlist: Array[AudioStream] = []
var _current_index: int = -1


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.volume_db = volume_db
	_player.finished.connect(_on_track_finished)
	add_child(_player)

	_playlist = tracks.duplicate()
	if shuffle:
		_playlist.shuffle()

	if not _playlist.is_empty():
		_play_track(0)
	else:
		push_warning("MusicManager: no tracks assigned in the 'tracks' export")


func _play_track(index: int) -> void:
	if _playlist.is_empty():
		return
	_current_index = index
	var stream := _playlist[_current_index]
	if stream:
		_player.stream = stream
		_player.play()


func _on_track_finished() -> void:
	var next_index := (_current_index + 1) % _playlist.size()
	if next_index == 0 and shuffle:
		_playlist.shuffle()   # reshuffle each time the playlist loops back to the start
	_play_track(next_index)


## Optional helpers if you want a mute/skip button later.
func skip_to_next() -> void:
	if not _playlist.is_empty():
		_on_track_finished()


func set_music_volume_db(db: float) -> void:
	volume_db = db
	if _player:
		_player.volume_db = db
