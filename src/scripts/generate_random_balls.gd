class_name GeneratePlanets extends MultiMeshInstance3D


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
@onready var parent := get_parent() as BlueNoiseGen
@onready var planets:Array[Planet] = []
@onready var cam := get_tree().root.get_viewport().get_camera_3d()
# Called when the node enters the scene tree for the first time.
func _ready():
#	parent.generate_done.connect(on_generate_done)
	pass
func init_map(chunks:Dictionary) -> void:
	var values : Array[Planet] = []
	for chunk_key in chunks:
		var chunk : Array = chunks[chunk_key]
		for pos in chunk:
			var pos3 := Vector3(pos.x,randf_range(-1,1),pos.y)
			var stats := PlanetStats.new()
			var names := PlanetStats.SYSTEM_NAMES
			stats.name = names[randi() % names.size()]
			
			stats.num_of_moons = randi()%5
			stats.planet_type = randi()%PlanetStats.PLANET_TYPE_VALUES.size() as PlanetStats.PlanetType
			stats.star_color = possible_colors[randi()%possible_colors.size()]
			stats.star_scale = roundi(randf_range(min_scale,max_scale))
			values.append(Planet.new(pos3,stats))
			pass
		planets = values
		multimesh.instance_count = planets.size()
		refresh_map()
		
func init_from_planets() -> void:
	multimesh.instance_count = planets.size()
	
func refresh_map() -> void:
	for i in planets.size():
		var planet : Planet = planets[i]
		var trans := Transform3D(Basis(),planet.position)
		trans = trans.scaled_local(Vector3.ONE*planet.stats.star_scale)
		multimesh.set_instance_transform(i,trans)
#		var col := Color(randf_range(0.5,1),randf_range(0.5,1),randf_range(0.5,1),1)
		var col := planet.stats.star_color
		multimesh.set_instance_color(i,col)
		multimesh.set_instance_custom_data(i,col)
func on_generate_done() -> void:
#	visibility_range_end = parent.sector_size_in_units * parent.sector_count_axis * 2
#	refresh_map(parent.chunks)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#	refresh_map()
	pass

class Planet:
	var position:Vector3
	var stats:PlanetStats
	func _init(position:Vector3,stats:PlanetStats):
		self.position=position
		self.stats=stats
	func to_bytes() -> PackedByteArray:
		var arr := PackedByteArray()
		arr.resize(16)
		arr.encode_var(0,position)
		arr.append_array(stats.to_bytes())
		return arr
	
	static func from_bytes(bytes:PackedByteArray) -> Planet:
		return Planet.new(
			bytes.decode_var(0),
			PlanetStats.from_bytes(bytes.slice(16))
		)
