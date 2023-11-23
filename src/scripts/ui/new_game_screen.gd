class_name NewGameScreen extends Control

@onready var player_manager : PlayerManager = GameState.get_node("Players")
@export_dir var _dir_name:String


signal start_game()

@export_group("GUI Items", "_gui_")
@export var _gui_race_selector : RaceSelector
@export var _gui_color_selector : ColorSelector
@export var _gui_player_list : PlayerList
@export var _gui_match_button : MatchButton

func _ready() -> void:
	if multiplayer.is_server():
		_clear_ready_components()
		
	for player in player_manager.players.values():
		add_player_to_list(player)

func _on_local_player_loaded(player:PlayerData) -> void:
	pass

func add_player_to_list(player:PlayerData) -> void:
	print("adding player %s to list" % [player.player_id])
	var idx := player.player_id
	if player == (GameState.get_node("Players") as PlayerManager).local_player:
		var local_player := player
		local_player.color_changed.connect(func(_o,c): _change_local_color(c))
		if multiplayer.is_server():
			PlayerReady.change_ready_for(local_player)
			_gui_match_button.text = "Start Game"
		else:
			_gui_match_button._on_ready_changed(local_player)
			var has_ready_node := PlayerReady.is_ready(local_player)
			_gui_match_button.text = "Ready" if !has_ready_node else "Not Ready"
	
	print("%s -- Adding %s to list" % [str(multiplayer.get_unique_id()),str(idx)])
	
	var c_idx := _get_first_available_color_idx()
	if not _gui_race_selector.is_node_ready():
		await _gui_race_selector.ready
	player.color = _gui_color_selector.pickable_colors[c_idx]
	player.race = _gui_race_selector.pickable_races[0]
	
	player.color_changed.connect(_change_color_availability)
	_refresh_colors_available()

func _enable_match_button(enable:bool):
	_gui_match_button.disabled = !enable

@rpc("call_local", "authority")
func _start_match():
	if multiplayer.is_server():
		_clear_ready_components()
		_remove_self()
		start_game.emit()
	
func _clear_ready_components() -> void:
	for player in player_manager.players.values().filter(func(x:PlayerData):return PlayerReady.is_ready(x)):
		PlayerReady.change_ready_for(player)
		

func _remove_self() -> void:
	var parent := get_parent()
	if parent:
		parent.remove_child(self)
		self.queue_free()
		
func _are_players_ready() -> bool:
	var ret := player_manager.is_everyone_ready()
	return ret
	
### gimme docs
func _on_match_start():
	if multiplayer.is_server():
		_start_match.rpc()

func _get_local_or_sender_player(sender:int=0) -> PlayerData:
	print(sender)
	return player_manager.local_player if sender == 0 else player_manager.players[str(sender)]

func _on_local_ready_change(_node:Node) -> void:
	if not multiplayer || _node != player_manager.local_player:
		return
	# var has_ready_node :=  PlayerReady.is_ready(player_manager.local_player)
	# print("is local player %s ready? %s" % [multiplayer.get_unique_id(), has_ready_node])
	# _gui_match_button.text = "Ready" if !has_ready_node else "Not Ready"


@rpc("any_peer")
func _change_ready() -> void:
	if multiplayer.is_server():
		var player := _get_local_or_sender_player(multiplayer.get_remote_sender_id())
		PlayerReady.change_ready_for(player)
	else:
		_change_ready.rpc_id(1)
	
	
func remove_player_from_list(_player:PlayerData):
	_refresh_colors_available()
	pass
	
# Called when the node enters the scene tree for the first time.

func _get_first_available_color_idx() -> int:
	var curr_colors := player_manager.players.values().map(func(x:PlayerData):return x.color)
	if curr_colors.size() == 0:
		return 0
	for i in _gui_color_selector.pickable_colors.size():
		if not _gui_color_selector.pickable_colors[i] in curr_colors:
			return i
	return -1

func _change_color_availability(_enable_color:Color,_disable_color:Color):
	_refresh_colors_available()

func _refresh_colors_available() -> void:
	var colors := player_manager.players.values().map(func(x:PlayerData): return x.color)
	for i in _gui_color_selector.item_count:
		var tx := _gui_color_selector.get_item_icon(i) as GradientTexture2D
		var tx_color := tx.gradient.get_color(0)
		_gui_color_selector.set_item_disabled(i, colors.has(tx_color))
	pass

@rpc("any_peer")
func _on_race_changed_idx(idx:int):
	if multiplayer.is_server():
		var child := _get_local_or_sender_player(multiplayer.get_remote_sender_id())
		child.race = _gui_race_selector.pickable_races[idx]
	else:
		_on_race_changed_idx.rpc_id(1,idx)
		
@rpc("any_peer")
func _on_color_changed_idx(idx:int) -> void:
	if multiplayer.is_server():
		var child := _get_local_or_sender_player(multiplayer.get_remote_sender_id())
		child.color = _gui_color_selector.pickable_colors[idx]
	else:
		_on_color_changed_idx.rpc_id(1,idx)
	
func _change_local_color(color:Color):
	var idx := _gui_color_selector.pickable_colors.find(color)
	print("color for %s is %s" % [multiplayer.get_unique_id(),idx])
	_gui_color_selector.selected = idx
	pass
	


