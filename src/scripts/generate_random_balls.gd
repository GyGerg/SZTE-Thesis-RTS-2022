class_name GeneratePlanets extends MultiMeshInstance3D


@export var min_scale :float = .8
@export var max_scale :float = 5
@export var dictio : Dictionary = {
	PlanetStats.PlanetType.EarthLike: Color.DARK_ORANGE,
	PlanetStats.PlanetType.Exotic: Color.LIGHT_BLUE,
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

@onready var cam := get_tree().root.get_viewport().get_camera_3d()
# Called when the node enters the scene tree for the first time.
func _ready():
	parent.generate_done.connect(on_generate_done)
	pass


func refresh_map() -> void:
	multimesh.instance_count = 0
	var values : Array[Vector2] = []
	for chunk_key in parent.chunks:
		var chunk : Array = parent.chunks[chunk_key]
		values.append_array(chunk.map(func(x):return x as Vector2))
	multimesh.instance_count = values.size()
	for i in values.size():
		var pos : Vector2 = values[i]
		var trans := Transform3D(Basis(),Vector3(pos.x,randf_range(-1,1),pos.y))
		trans = trans.scaled_local(Vector3.ONE*randf_range(min_scale,max_scale))
		multimesh.set_instance_transform(i,trans)
#		var col := Color(randf_range(0.5,1),randf_range(0.5,1),randf_range(0.5,1),1)
		var col := possible_colors[randi()%possible_colors.size()]
		multimesh.set_instance_color(i,col)
		multimesh.set_instance_custom_data(i,col)
func on_generate_done() -> void:
	visibility_range_end = parent.sector_size_in_units * parent.sector_count_axis * 2
	multimesh.instance_count = 0
	var values : Array[Vector2] = []
	for chunk_key in parent.chunks:
		var chunk : Array[Vector2] = parent.chunks[chunk_key] as Array[Vector2]
		values.append_array(chunk)#.map(func(x):return x as Vector2))
	multimesh.instance_count = values.size()
	for i in values.size():
		var pos : Vector2 = values[i]
		var trans := Transform3D(Basis(),Vector3(pos.x,randf_range(-1,1),pos.y))
		trans = trans.scaled_local(Vector3.ONE*randf_range(min_scale,max_scale))
		multimesh.set_instance_transform(i,trans)
#		var col := Color(randf_range(0.5,1),randf_range(0.5,1),randf_range(0.5,1),1)
		var col := possible_colors[randi()%possible_colors.size()]
		multimesh.set_instance_color(i,col)
		multimesh.set_instance_custom_data(i,col)
	print(values[0])
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#	refresh_map()
	pass
