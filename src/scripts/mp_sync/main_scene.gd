class_name MainNode extends Node

@export var shared_ui_container : Control
@onready var shared_game_container := GameState
@onready var player_manager := GameState.get_node("Players") as PlayerManager
const new_game_screen : PackedScene = preload("res://src/scenes/ui/new_game_screen.tscn")
# todo: place it somewhere else
const match_scene := preload("res://trial_scene_planet_gen.tscn")

const PORT := 4433

# Called when the node enters the scene tree for the first time.
func _ready():
	MpManager.peer_initialized.connect(load_lobby)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func load_lobby():
	print("load lobby called")
	var ng_screen := new_game_screen.instantiate() as NewGameScreen
	if multiplayer.is_server():
		ng_screen.start_game.connect(load_game, CONNECT_ONE_SHOT)
	shared_ui_container.add_child(ng_screen)
	

func load_game():
	var new_child := match_scene.instantiate() as Match
	if new_child:
		add_child(new_child)

func _on_peer_created() -> void:
	MpManager._on_peer_created()
	pass
	
func _on_peer_destroyed():
	pass

func _create_player(idx:int):
	player_manager.create_player(idx)
	
func _remove_player(idx:int):
	player_manager.remove_player(idx)
