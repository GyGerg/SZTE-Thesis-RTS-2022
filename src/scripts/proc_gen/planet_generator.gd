class_name GeneratePlanets extends MultiMeshInstance3D

signal planet_gen_done(planets:Array[Planet])


@export var min_scale :float = .8
@export var max_scale :float = 5
@export var dictio : Dictionary = {
	PlanetStats.PlanetType.EarthLike: PackedColorArray([Color.DARK_ORANGE]),
	PlanetStats.PlanetType.Exotic: PackedColorArray([Color.LIGHT_BLUE]),
}
@export var ar : Array[PlanetStats.PlanetType]
const possible_colors : Array[Color] = [
	Color.DARK_ORANGE,
	Color.CORAL,
	Color.SKY_BLUE,
	Color.RED,
	Color.TOMATO,
	Color.ORANGE_RED,
	Color.LIGHT_BLUE,
	Color.GHOST_WHITE
]
@export var possible_planets : Array[PlanetStats]

@export var generator : BlueNoiseGenerator
@onready var planet_chunks:Dictionary = {}
@onready var planets:Array[Planet] = []
@onready var map_size : float = generator.SectorCountAxis * generator.SectorSizeInUnits

signal map_size_calculated(map_axis_size:float)
# Called when the node enters the scene tree for the first time.
func _ready():
	map_size_calculated.emit(map_size)
	pass
func init_map(num_of_players:int) -> void:
	var chunks : Dictionary = generator.Generate(num_of_players)
	var values : Array[Planet] = []
	for chunk_key in chunks:
		var planet_chunk: Array[Planet] = []
		var chunk : PackedVector2Array = chunks[chunk_key]
		for pos in chunk:
			var pos3 := Vector3(pos.x,randf_range(-1,1),pos.y)
			var stats := PlanetStats.new()
			var names := PlanetStats.SYSTEM_NAMES
			stats.name = names[randi() % names.size()]
			stats.num_of_moons = randi()%5
			stats.planet_type = randi()%PlanetStats.PLANET_TYPE_VALUES.size() as PlanetStats.PlanetType
			stats.star_color = possible_colors[randi()%possible_colors.size()]
			stats.star_scale = roundi(randf_range(min_scale,max_scale))
			
			var planet := Planet.new(pos3, stats)
			planet_chunk.append(planet)
			values.append(planet)
		planet_chunks[chunk_key] = planet_chunk
#		values.append_array(planet_chunk)
	planets = values
	multimesh.instance_count = planets.size()
	planet_gen_done.emit(planets)
#		refresh_map()
		
func init_from_planets() -> void:
	multimesh.instance_count = planets.size()
	
func refresh_map() -> void:
	for i in planets.size():
		var planet : Planet = planets[i]
		var trans := Transform3D(Basis(),planet.position)
		trans = trans.scaled_local(Vector3.ONE*planet.stats.star_scale)
		multimesh.set_instance_transform(i,trans)
		
		var col := planet.stats.star_color
		multimesh.set_instance_color(i,col)
		multimesh.set_instance_custom_data(i,col)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#	refresh_map()
	pass

