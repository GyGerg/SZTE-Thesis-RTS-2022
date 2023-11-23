class_name MpManagerClass extends Node


@onready var player_manager : PlayerManager = GameState.get_node("Players")
const PORT := 4433

signal peer_created()
signal peer_initialized()
signal peer_left(idx:int)

func start_client(ip:String,port:int=PORT) -> ENetMultiplayerPeer:
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(ip,port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Lmao couldn't join to %s ya knob" % ip+":"+str(port))
		return
		
	multiplayer.multiplayer_peer=peer
	peer_created.emit()
	return peer
	
func start_server(player_count:int,port:int=PORT) -> ENetMultiplayerPeer:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(port,player_count)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Lmao couldn't start a server ya knob")
		return
		
	multiplayer.multiplayer_peer = peer
	peer_created.emit()
	return peer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _on_peer_created():
	print("on peer created emit consumed")
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_create_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		for peer in multiplayer.get_peers():
			_create_player(peer)
		_create_player(1)
		
		print("emitting peer_initialized")
		peer_initialized.emit()
	pass
func _on_peer_destroyed():
	pass

func _create_player(idx:int):
	player_manager.create_player(idx)
	
func _remove_player(idx:int):
	player_manager.remove_player(idx)
	peer_left.emit(idx)
