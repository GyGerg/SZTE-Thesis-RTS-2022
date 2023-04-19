class_name Draw3D extends Object

static func draw_empty_circle(mesh:ImmediateMesh, center:Vector3, radius:float, resolution:int, material:Material) -> void:

	var sppi : float = 2 * PI / resolution
	var arr : Array[Vector3] = []
	arr.resize(resolution)
	for i in range(resolution):
		
		var rot := float(i)/resolution * TAU
		arr[i] = center+(Vector3.RIGHT*radius).rotated(Vector3.UP, rot)
	
	draw_line_strip(mesh,arr,material)
	pass

static func draw_line(mesh:ImmediateMesh, from:Vector3, to:Vector3, material:Material) -> void:
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	mesh.surface_set_normal(Vector3.UP)
	mesh.surface_set_uv(Vector2.ONE)
	
	mesh.surface_add_vertex(from)
	mesh.surface_add_vertex(to)
	
	mesh.surface_end()
static func draw_line_strip(mesh:ImmediateMesh, vertices:Array[Vector3],material:Material, is_looping:bool=true) -> void:
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, material)
	
	mesh.surface_set_normal(Vector3.UP)
	mesh.surface_set_uv(Vector2.ONE)
	if is_looping && vertices[0] != vertices[-1]:
		vertices.append(vertices[0])
	for v in vertices:
		mesh.surface_add_vertex(v)
		
	mesh.surface_end()
