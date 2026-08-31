extends Node
## Autoload this as "PlayerManager" (Project Settings > Autoload).
## Tracks all Player instances in the current level and handles swap logic.

signal player_swapped(active_player: Player, inactive_player: Player)

var players: Array[Player] = []
var active_index: int = 0

var swap_cooldown: float = 0.15   # prevents accidental double-swaps
var _swap_timer: float = 0.0


func _process(delta: float) -> void:
	if _swap_timer > 0.0:
		_swap_timer -= delta


func register_player(player: Player) -> void:
	if player in players:
		return
	players.append(player)
	players.sort_custom(func(a, b): return a.player_id < b.player_id)
	_update_active_states()


func unregister_player(player: Player) -> void:
	players.erase(player)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("swap_player") and _swap_timer <= 0.0:
		swap_player()


func swap_player() -> void:
	if players.size() < 2:
		return
	active_index = (active_index + 1) % players.size()
	_swap_timer = swap_cooldown
	_update_active_states()


func _update_active_states() -> void:
	if players.is_empty():
		return
	for i in players.size():
		players[i].set_active(i == active_index)
	var active_player := players[active_index]
	var inactive_player: Player = players[(active_index + 1) % players.size()] if players.size() > 1 else null
	player_swapped.emit(active_player, inactive_player)


func get_active_player() -> Player:
	return players[active_index] if not players.is_empty() else null


func reset() -> void:
	# Call this before loading a new level so stale player references
	# from the previous scene don't linger.
	players.clear()
	active_index = 0
