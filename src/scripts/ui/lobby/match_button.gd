class_name MatchButton extends Button

const _START_GAME_TEXT := "Start Game"
const _READY_TEXT := "Ready"
const _NOT_READY_TEXT := "Not ready"

signal match_wait_started()
signal match_start()

func _ready() -> void:
	text = _START_GAME_TEXT if multiplayer.is_server() else _READY_TEXT

func _on_ready_changed(player:PlayerData):
	if not is_inside_tree():
		return
	if multiplayer.is_server():
		var manager := get_node("/root/GameState/Players") as PlayerManager
		disabled = !manager.is_everyone_ready()
	elif player == ($"/root/GameState/Players" as PlayerManager).local_player:
		text = _READY_TEXT if !PlayerReady.is_ready(player) else _NOT_READY_TEXT

func _pressed() -> void:
	if multiplayer.is_server():
		if (GameState.get_node("Players") as PlayerManager).is_everyone_ready():
			_start_match.rpc()
	else:
		_change_ready()

@rpc("any_peer")
func _change_ready() -> void:
	if multiplayer.is_server():
		var sender := multiplayer.get_remote_sender_id()
		var player_manager := get_node("/root/GameState/Players") as PlayerManager
		var player : PlayerData = player_manager.local_player if sender == 0 else player_manager.players[str(sender)]
		PlayerReady.change_ready_for(player)
	else:
		_change_ready.rpc_id(1)

@rpc("call_local", "authority")
func _start_match():
	match_wait_started.emit()
	disabled = true
	
	var countdown_timer := CountdownTimer.new(5)
	add_child(countdown_timer)
	text = "%s..." % str(5)
	countdown_timer.second_passed.connect(func(x:int):
		text = "%s..." % str(x))
	await countdown_timer.tree_exited
	if multiplayer.is_server():
		match_start.emit()
