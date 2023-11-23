extends Node

signal player_spawned(player:PlayerData)
signal player_left(player:PlayerData)
signal player_leaving(player:PlayerData)

signal player_ready_changed(player:PlayerData)
signal local_player_loaded(player:PlayerData)

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_manager : PlayerManager = get_node("/root/GameState/Players")
	player_manager.local_player_loaded.connect(func(player:PlayerData): local_player_loaded.emit(player))
	player_manager.player_ready_changed.connect(func(player:PlayerData): player_ready_changed.emit(player))
	player_manager.player_spawned.connect(func(player:PlayerData): player_spawned.emit(player))
	player_manager.player_left.connect(func(player:PlayerData): player_left.emit(player))
	player_manager.player_leaving.connect(func(player:PlayerData): player_leaving.emit(player))


	pass # Replace with function body.

func _on_match_start():
	var player_manager : PlayerManager = get_node("/root/GameState/Players")
	for connection in player_manager.player_ready_changed.get_connections():
		player_manager.player_ready_changed.disconnect(connection)
