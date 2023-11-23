class_name PlayerAwaiter extends Node

signal everyone_ready()

static func _playermanager() -> PlayerManager:
		return GameState.get_node("Players") as PlayerManager
# Called when the node enters the scene tree for the first time.
func _ready():
	var manager := PlayerAwaiter._playermanager()
	
	manager.player_leaving.connect(_check_if_players_ready)
	manager.player_left.connect(_check_if_players_ready)
	manager.player_ready_changed.connect(_check_if_players_ready)
	_check_if_players_ready(null)

func _check_if_players_ready(_val:PlayerData):
	if multiplayer && multiplayer.is_server():
		var manager := PlayerAwaiter._playermanager()
		if manager.players.values().all(PlayerReady.is_ready):
				everyone_ready.emit()
				for player in manager.players.values():
					PlayerReady.change_ready_for(player)
				queue_free()
