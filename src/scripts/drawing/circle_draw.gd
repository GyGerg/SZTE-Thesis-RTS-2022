class_name CircleDraw extends ImmediateMesh



@export_range(4,360) var resolution : int = 180
@export var color:Color = Color.GREEN
@export var radius:float = 2

@export var mat : StandardMaterial3D = StandardMaterial3D.new()
func draw_empty_circle(center:Vector3,radius:float) -> void:
	surface_begin(Mesh.PRIMITIVE_LINE_STRIP, mat)
	surface_set_normal(Vector3.UP)
	surface_set_uv(Vector2.ONE)
	surface_set_color(color)
	
	var sppi : float = 2 * PI / resolution
	for i in resolution:
		var rot := float(i)/resolution * TAU
		surface_add_vertex(center+(Vector3.RIGHT*radius).rotated(Vector3.UP, rot))
		
	surface_end()
	pass

func _process(_delta):
	clear_surfaces()
	draw_empty_circle(Vector3.ZERO,radius)
	pass
