extends Node
## Autoload this as "MusicManager" (Project Settings > Autoload).
## Scans `music_folder` for audio files, plays them back-to-back, and loops
## the whole playlist once it reaches the end. Because this is an autoload,
## it lives outside the scene tree that gets swapped on level load/restart,
## so the music is never interrupted by LevelManager's scene changes.

@export var music_folder: String = "res://music"
@export var shuffle: bool = true
@export var volume_db: float = -6.0

var _player: AudioStreamPlayer
var _playlist: Array[String] = []
var _current_index: int = -1


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.volume_db = volume_db
	_player.finished.connect(_on_track_finished)
	add_child(_player)

	_playlist = _scan_music_folder(music_folder)
	if shuffle:
		_playlist.shuffle()

	if not _playlist.is_empty():
		_play_track(0)
	else:
		push_warning("MusicManager: no audio files found in %s" % music_folder)


func _scan_music_folder(path: String) -> Array[String]:
	var results: Array[String] = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("MusicManager: could not open folder %s" % path)
		return results

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and _is_audio_file(file_name):
			results.append(path.path_join(file_name))
		file_name = dir.get_next()
	dir.list_dir_end()

	results.sort()  # deterministic order before an optional shuffle
	return results


func _is_audio_file(file_name: String) -> bool:
	var lower := file_name.to_lower()
	return lower.ends_with(".ogg") or lower.ends_with(".mp3") or lower.ends_with(".wav")


func _play_track(index: int) -> void:
	if _playlist.is_empty():
		return
	_current_index = index
	var stream := load(_playlist[_current_index]) as AudioStream
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
