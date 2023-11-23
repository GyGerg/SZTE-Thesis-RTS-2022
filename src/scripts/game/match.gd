class_name Match extends Node3D

signal player_ready()
signal map_loaded()

signal map_gen_requested()

signal start_point_determined(coords:Vector2)

@export var planet_gen : GeneratePlanets

@export var map_data : MapData

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		var players := (GameState.get_node("Players") as PlayerManager).players
		var player_ids := players.keys()
		var player_count := players.size()
		
		PlayerReady.change_ready_for(players["1"])
		print("SERVER -- awaiter called")
		var awaiter := PlayerAwaiter.new()
		add_child(awaiter)
		await awaiter.tree_exited
		print("SERVER -- awaiter finished")
		
		planet_gen.init_map(player_count)
	else:
		_on_player_ready.rpc_id(1, multiplayer.get_unique_id())
	pass # Replace with function body.
			
@rpc("authority", "call_local")
func _server_start_point_signal(coords:Vector2):
	print("%s -- start position received: %s" % [multiplayer.get_unique_id(),coords])
	start_point_determined.emit(coords)

@rpc("authority","call_local","unreliable")
func refresh_map():
	planet_gen.refresh_map()
	if not multiplayer.is_server():
		_on_player_ready.rpc_id(1,multiplayer.get_remote_sender_id())

func send_planet_data():
	if multiplayer.is_server():
		var arr : Array[PackedByteArray] = []
		var planets := planet_gen.planets
		var len = planets.size()
		arr.resize(len)
		for i in len:
			arr[i] = planets[i].to_bytes()
		deserialize_planet_data.rpc(arr)
		
func repartition_planets():
	if multiplayer.is_server():
		var x_coords := planet_gen.planets.map(func(planet:Planet):
			return planet.position.x)
		var y_coords := planet_gen.planets.map(func(planet:Planet):
			return planet.position.y)
		var lowest := Vector2(x_coords.min(), y_coords.min())
		var highest := Vector2(x_coords.max(), y_coords.max())
		var size := highest.distance_to(lowest)
		pass
	
@rpc("authority")
func deserialize_planet_data(planets_serialized:Array):
	for planet_data in planets_serialized:
		planet_gen.planets.append(Planet.from_bytes(planet_data))
	
	planet_gen.init_from_planets()
	planet_gen.refresh_map()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc("any_peer","call_local")
func _on_map_loaded():
	print("FROM CLIENT -- %s map loaded" % str(multiplayer.get_remote_sender_id()))
	map_loaded.emit()

@rpc("any_peer")
func _on_player_ready(player_id:int):
	PlayerReady.change_ready_for((GameState.get_node("Players") as PlayerManager).players[str(player_id)])


func _on_planet_gen_done(planets:Array[Planet]):
	if multiplayer.is_server():
		send_planet_data()
		map_data.game_planets = {}
		map_data.game_planets["unoccupied"] = []
		map_data.game_planets["unoccupied"].assign(planet_gen.planets) # jesus fucking christ why
		var unoccupied : Array = map_data.game_planets["unoccupied"] # de ha ez meg fog copyt csinálni én felkötöm magam
		
		var players := (GameState.get_node("Players") as PlayerManager).players
		var player_ids := players.keys()
		var player_count := players.size()
		print("SERVER -- map loaded for everyone")
		for player_id in player_ids:
			map_data.game_planets[player_id] = []
		var planet_chunks := planet_gen.planet_chunks.values()
		planet_chunks.shuffle()
		print("SERVER -- chunks shuffled")
		for i in player_count:
			var possible_planets : Array = planet_chunks[i].filter(func(x:Planet): return unoccupied.has(x))
			print("possible planet count: %s" % possible_planets.size())
			var start_planet : Planet = (possible_planets[randi() % possible_planets.size()] as Planet)
			print("start planet: %s" % start_planet.position)
			var start_pos_3 := start_planet.position
			map_data.game_planets[player_ids[i]].append(unoccupied.pop_at(
				unoccupied.find(start_planet)))
			print("SERVER -- sending startPos message")
			_server_start_point_signal.rpc_id(int(player_ids[i]),Vector2(start_pos_3.x,start_pos_3.z))
		
		_on_map_loaded.rpc()
#		planet_gen._on_planet_gen_done
		print("SERVER -- map loaded for every player")
		refresh_map()
	else:
		_on_player_ready.rpc_id(1, multiplayer.get_unique_id())
	pass # Replace with function body.
