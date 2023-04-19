class_name Match extends Node3D

signal player_ready()
signal map_loaded()

@export var generator : BlueNoiseGen
@export var planet_gen : GeneratePlanets
# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		var player_size := (GameState.get_node("Players") as PlayerManager).players.size()-1 # except server
		for i in player_size:
			await player_ready
		generator.generate()
		planet_gen.init_map(generator.chunks)
		var arr_to_send := planet_gen.planets.map(func(x:GeneratePlanets.Planet): 
			return x.to_bytes())
		send_planet_data.rpc(arr_to_send)
		refresh_map()
		for i in player_size:
			await map_loaded
		print("SERVER -- map loaded for every player")
	else:
		_on_player_ready.rpc_id(1)
	pass # Replace with function body.

@rpc("authority","call_local","unreliable")
func refresh_map():
	planet_gen.refresh_map()
	if not multiplayer.is_server():
		_on_map_loaded.rpc_id(1)

@rpc("authority","unreliable")
func send_planet_data(planets:Array):
	planet_gen.planets = []
	for planet in planets.map(func(x:PackedByteArray):return GeneratePlanets.Planet.from_bytes(x)):
		planet_gen.planets.append(planet as GeneratePlanets.Planet)
	
	planet_gen.init_from_planets()
	planet_gen.refresh_map()
	_on_map_loaded.rpc_id(1)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc("any_peer","unreliable")
func _on_map_loaded():
	print("FROM CLIENT -- %s map loaded" % str(multiplayer.get_remote_sender_id()))
	map_loaded.emit()
@rpc("any_peer","unreliable")
func _on_player_ready():
	player_ready.emit()

