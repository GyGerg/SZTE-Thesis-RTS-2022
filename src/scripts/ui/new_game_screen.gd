class_name NewGameScreen extends Control

@onready var shared : PlayerManager = GameState.get_node("Players")
@export_dir var _dir_name:String

@export_group("GUI Items", "_gui_")
@export var _gui_race_selector : RaceSelector
@export var _gui_color_selector : ColorSelector
@export var _gui_player_list : PlayerList
@export var _gui_match_button : Button

var local_player:PlayerData


func _ready():
	print("ng screen ready called")
#	if _gui_race_selector.pickable_races == null || _gui_race_selector.pickable_races.size() == 0:
#		await _gui_race_selector.ready
	
	
	print("OUR ID IS: %s" % str(multiplayer.get_unique_id()))
	if multiplayer.is_server():
		shared.local_player.add_child(PlayerData.ReadyPrefab.instantiate())
	
	shared.player_spawned.connect(add_player_to_list)
	shared.player_leaving.connect(remove_player_from_list)
	
	for player in shared.players.values():
		add_player_to_list(player as PlayerData)
	_refresh_colors_available()
	
	### local player-related work
	while shared.local_player == null:
		await shared.player_spawned
		
	shared.local_player.color_changed.connect(func(o,col):
		_change_local_color(col))

		
	_change_local_color(shared.local_player.color)
	
	### instant ready as server, can't change ready-state
	if multiplayer.is_server():
		_gui_match_button.text = "Start Game"
	else:
		var has_node := shared.local_player.has_node("PlayerReady")
		_gui_match_button.text = "Ready" if !has_node else "Not Ready"
		shared.local_player.child_entered_tree.connect(_on_local_ready_change)
		shared.local_player.child_exiting_tree.connect(func(x:Node):
			await x.tree_exited
			_on_local_ready_change(x)
		)
	pass # Replace with function body.


func add_player_to_list(player:PlayerData):
	var idx := player.player_id
	print("%s -- Adding %s to list" % [str(multiplayer.get_unique_id()),str(idx)])
	
	var c_idx := _get_first_available_color_idx()
	player.color = _gui_color_selector.pickable_colors[c_idx]
	player.race = _gui_race_selector.pickable_races[0]
	
	player.color_changed.connect(_change_color_availability)
	_refresh_colors_available()
	
	if multiplayer.is_server():
		_enable_match_button(_are_players_ready())
		player.child_entered_tree.connect(func(x): 
			if not x is PlayerReady:
				return
			_enable_match_button(_are_players_ready())
			)
		player.child_exiting_tree.connect(func(x): 
			if not x is PlayerReady:
				return
			await x.tree_exited
			_enable_match_button(_are_players_ready())
			)
		pass
	pass

func _enable_match_button(enable:bool):
	_gui_match_button.disabled = !enable

@rpc("call_local", "authority", "unreliable")
func _start_match():
	_enable_match_button(false)
	
	var countdown_timer := CountdownTimer.new(5)
	add_child(countdown_timer)
	_gui_match_button.text = "%s..." % str(5)
	countdown_timer.second_passed.connect(func(x:int):
		_gui_match_button.text = "%s..." % str(x))
	await countdown_timer.tree_exited
	
	_clear_ready_components()
	if multiplayer.is_server():
		var parent := get_parent()
		parent.remove_child(self)
		self.queue_free()
	
	OS.alert("Game is running ya dingus")
	
func _clear_ready_components() -> void:
	if multiplayer.is_server():
		for player in shared.players.values().filter(func(x:PlayerData):x.has_node("PlayerReady")):
			var child : Node = player.get_node("PlayerReady")
			player.remove_child(child)
			child.queue_free()
			
func _are_players_ready() -> bool:
	var ret := shared.players.values().all(func(x:PlayerData):return x.has_node("PlayerReady"))
	return ret
	
### gimme docs
func _on_match_button_click():
	if multiplayer.is_server():
		print("STARTING GAME WOOOOOOOOO")
		_start_match.rpc()
		pass
	else:
		_change_ready()
	
	
func _on_local_ready_change(node:Node):
	var has_node :=  shared.local_player.has_node("PlayerReady")
	_gui_match_button.text = "Ready" if !has_node else "Not Ready"


func _change_ready_for(player:PlayerData):
	var has_node := player.has_node("PlayerReady")
	print("CLIENT: player %s has ready node: %s" % [str(multiplayer.get_unique_id()),str(has_node)])
	if has_node:
		var chld := player.get_node("PlayerReady")
		player.remove_child(chld)
		chld.queue_free()
	else:
		player.add_child(PlayerData.ReadyPrefab.instantiate())
	
func _change_ready():
	var player := shared.local_player
	_change_ready_for(player)
	
func _change_ready_remote():
	var sender := multiplayer.get_remote_sender_id()
	if sender == 0:
		return
	_change_ready_for(shared.players[str(sender)])
	
	
	
func remove_player_from_list(player:PlayerData):
	_refresh_colors_available()
	pass
	
# Called when the node enters the scene tree for the first time.

func _get_first_available_color_idx() -> int:
	var curr_colors := shared.players.values().map(func(x:PlayerData):return x.color)
	if curr_colors.size() == 0:
		return 0
	for i in _gui_color_selector.pickable_colors.size():
		if not _gui_color_selector.pickable_colors[i] in curr_colors:
			return i
	return -1

func _change_color_availability(_enable_color:Color,_disable_color:Color):
	_refresh_colors_available()

func _refresh_colors_available() -> void:
	var colors := shared.players.values().map(func(x:PlayerData): return x.color)
	for i in _gui_color_selector.item_count:
		var tx := _gui_color_selector.get_item_icon(i) as GradientTexture2D
		var tx_color := tx.gradient.get_color(0)
		_gui_color_selector.set_item_disabled(i, colors.has(tx_color))
	pass

func _on_race_changed_idx(idx:int):
	var child : PlayerData = shared.local_player
	child.race = _gui_race_selector.pickable_races[idx]

func _on_color_changed_idx(idx:int) -> void:
	var child : PlayerData = shared.local_player
	child.color = _gui_color_selector.pickable_colors[idx]

	
func _change_local_color(color:Color):
	_gui_color_selector.selected = _gui_color_selector.pickable_colors.find(color)
	pass
	


