class_name PlayerManager extends MultiplayerSpawner

signal player_spawned(player:PlayerData)
signal player_left(player:PlayerData)
signal player_leaving(player:PlayerData)

const player_prefab : PackedScene = preload("res://src/scenes/state/player.tscn")

@onready var players: Dictionary

var local_player : PlayerData
# Called when the node enters the scene tree for the first time.
func _ready():
	child_entered_tree.connect(_call_player_spawned)
	child_exiting_tree.connect(_call_player_left)
	pass # Replace with function body.

func create_player(idx:int):
	var s_id := str(idx)
	print("%s joining" % s_id)
	
	var player := player_prefab.instantiate() as PlayerData
	player.player_id = idx
	player.name = "Player--%s" % s_id
	add_child(player)
	print("%s joined" % s_id)
	
func remove_player(idx:int):
	var s_id := str(idx)
	if players.has(s_id):
		var player : PlayerData = players[s_id]
		remove_child(player)
		player.queue_free()

func _call_player_spawned(node:Node):
	var child := node as PlayerData
	if not child:
		print(child.name)
		return
	await child.setup_done
	if child.player_id == multiplayer.get_unique_id():
		print("%s -- found local player" % str(multiplayer.get_unique_id()))
		local_player = child
		
	print("%s -- _call_player_spawned: Adding %s to list" % [str(multiplayer.get_unique_id()),str(child.player_id)])
	players[str(child.player_id)] = child
	player_spawned.emit(child)
	
	pass
func _call_player_left(node:Node):
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
