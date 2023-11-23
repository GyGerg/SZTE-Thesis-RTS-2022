class_name MapGenerator extends Node

@export var _generator: BlueNoiseGenerator
@export var _planet_gen: GeneratePlanets
# Called when the node enters the scene tree for the first time.

func generate_map(num_of_players:int):
	_planet_gen.init_map(num_of_players)
	var _chunks : Array[Array] = _planet_gen.planet_chunks.values()
	_chunks.shuffle()
	var players : Array[PlayerData] = (GameState.get_node("Players") as PlayerManager).players.values()
	for i in _chunks.size():
		var _chunk : Array[Planet] = _chunks[i]
		var _player := players
		pass
		
	
