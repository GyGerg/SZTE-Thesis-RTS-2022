class_name BlueNoiseGen extends Node3D

@export var sector_size_in_units:int = 2000
@export var sector_count_axis:int = 4
@export var density:float=3.0
@export_range(0.0,1) var sector_margin_proportion:float = .1
@export_range(0.0,1) var subsector_margin_proportion:float = .1

signal generate_done()
@onready var cell_width := ceili(sqrt(density))
@onready var subsector_count := cell_width*cell_width

@onready var sector_margin : float = sector_size_in_units * sector_margin_proportion

@onready var _subsector_base_size := (sector_size_in_units - sector_margin * 2) / cell_width
@onready var subsector_margin : float = _subsector_base_size * subsector_margin_proportion
@onready var _subsector_size := _subsector_base_size - subsector_margin*2

@onready var half_sector_size := sector_size_in_units/2.0
@onready var half_sector_count := int(sector_count_axis/2.0)

var chunks: Dictionary = {}


var _rng:=RandomNumberGenerator.new()

var start_seed := "try_me_lmao"
# Called when the node enters the scene tree for the first time.
func _ready():
	generate_done.connect(func():pass, CONNECT_ONE_SHOT)
#	if int(divved) != divved:
#		set_process(false)
#		return
	
	var start_time := Time.get_ticks_msec()
	generate()
	var end_time := Time.get_ticks_msec()
	var final_values:int = 0
	for chunk_key in chunks:
		var cnt := (chunks[chunk_key] as Array).size()
		print("%s - amount of items: %s" % [chunk_key, cnt])
		if cnt:
			final_values += cnt
	await get_tree().create_timer(0).timeout
	print("Generation finished in %s msec, final points size: %s" % [(end_time-start_time), str(final_values)])
	pass # Replace with function body.

### Returns a dictionary with Vector2 keys for positions (gonna bite me in the ass ig)
func generate() -> Dictionary:
	chunks.clear()
	if half_sector_count > 0:
		for x in range(-half_sector_count,half_sector_count+1):
			for y in range(-half_sector_count,half_sector_count+1):
				_generate_chunk(x,y)
	else:
		_generate_chunk(0,0)
	generate_done.emit()
	return chunks
	
func _generate_chunk(x:int,y:int) -> void:
	_rng.seed = make_hash(x,y)
#	seed(_rng.seed)
	var sector_top_left := Vector2(
		x * sector_size_in_units - half_sector_size + sector_margin,
		y * sector_size_in_units - half_sector_size + sector_margin
	)
	
	var sector_data : Array[Vector2] = []
	var sector_indices := range(subsector_count)
	sector_indices.shuffle()
	
	for i in range(density):
		var _x := int(sector_indices[i]/cell_width)
		var _y : int = sector_indices[i] - _x * cell_width
		sector_data.append(generate_random_position(Vector2(_x,_y),sector_top_left))
		pass
	chunks[Vector2(x,y)] = sector_data
	
func generate_random_position(subsec_coord:Vector2,sector_top_left:Vector2) -> Vector2:
	var subsec_top_left := (
		sector_top_left
		+(Vector2(_subsector_base_size,_subsector_base_size)*subsec_coord)
		+Vector2(subsector_margin,subsector_margin)	
	)
	var subsec_bot_right := subsec_top_left+Vector2.ONE*(_subsector_size)
	
	return Vector2(
		_rng.randf_range(subsec_top_left.x,subsec_bot_right.x),
		_rng.randf_range(subsec_top_left.y,subsec_bot_right.y)
	)
	
func make_hash(x:int,y:int):
	return ("%s %s %s" % [start_seed,x,y]).hash()
# Called every frame. 'delta' is the elapsed time since the previous frame.
