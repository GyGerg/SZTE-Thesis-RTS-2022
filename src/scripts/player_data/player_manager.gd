class_name PlayerManager extends MultiplayerSpawner

signal player_spawned(player:PlayerData)
signal player_left(player:PlayerData)
signal player_leaving(player:PlayerData)

signal player_ready_changed(player:PlayerData)
signal local_player_loaded(player:PlayerData)

const player_prefab : PackedScene = preload("res://src/scenes/state/player.tscn")

@onready var players: Dictionary

var local_player : PlayerData
# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		child_entered_tree.connect(_call_player_spawned)
		child_exiting_tree.connect(_call_player_left)
		
		multiplayer.server_disconnected.connect(clear_players)
		pass # Replace with function body.
	
## Instantiates a [PlayerData] for the given index
func create_player(idx:int):
	var s_id := str(idx)
	print("%s joining" % s_id)
	
	var player := player_prefab.instantiate() as PlayerData
	player.player_id = idx
	player.name = "Player--%s" % str(player.player_id)
	
	
	add_child(player)
	print("%s joined" % s_id)

## Removes a player from the manager instance.
func remove_player(idx:int):
	var s_id := str(idx)
	if players.has(s_id):
		var player : PlayerData = players[s_id]
		remove_child(player)
		player.queue_free()

func clear_players():
	local_player = null
	for node in players.values():
		remove_child(node)
		node.queue_free()
			
func _call_player_spawned(node:Node): # SERVER ONLY
	var child := node as PlayerData

	child.child_entered_tree.connect(func(node):
		if node is PlayerReady:
			player_ready_changed.emit(child))

	child.child_exiting_tree.connect(func(node):
		if node is PlayerReady:
			await node.tree_exited
			player_ready_changed.emit(child))

	if not child:
		print(child.name)
		return

	await child.ready
	var is_local_player := child.player_id == multiplayer.get_unique_id()
		
	print("%s -- _call_player_spawned: Adding %s to list" % [str(multiplayer.get_unique_id()),str(child.player_id)])
	players[str(child.player_id)] = child
	if is_local_player: 
		print("%s -- found local player" % str(multiplayer.get_unique_id()))
		local_player = child
		local_player_loaded.emit(child)
	player_spawned.emit(child)
	
	pass
func _call_player_left(node:Node): # SERVER ONLY
	var child := node as PlayerData
	player_leaving.emit(child)
	if child.player_id == multiplayer.get_unique_id():
		local_player = null
	if not child:
		print(child.name)
		return
	if players.has(str(child.player_id)):
		players.erase(str(child.player_id))
	player_left.emit(child)
	pass


func is_everyone_ready() -> bool:
	return players.values().all(func(x:PlayerData):return PlayerReady.is_ready(x))
