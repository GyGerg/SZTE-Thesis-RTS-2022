class_name HeightCursorMesh extends ImmediateMesh

@export var mat:Material
@export var mat2:Material
@export var color:Color

@export_range(3,180) var circle_resolution:int = 180
@export var circle_radius:float = 1
@export_range(90,360) var distance_circle_resolution:int = 180

func draw_empty_circle(center:Vector3,radius:float, resolution:int, material:Material) -> void:
	Draw3D.draw_empty_circle(self,center,radius,resolution,material)
	
func draw_line(from:Vector3,to:Vector3,material:Material) -> void:
	Draw3D.draw_line(self,from,to,material)

func draw_line_strip(vertices:Array[Vector3],material:Material, is_looping:bool=true):
	Draw3D.draw_line_strip(self,vertices,material,is_looping)
	
func update_cursor(heightPos:Vector3, horizontalPos:Vector3, startPos:Vector3):
	clear_surfaces()
	var distance := startPos.distance_to(horizontalPos)
	var dist_radius := distance/2
	
	var forward := Vector3.FORWARD
	var left := Vector3.LEFT
	# distance circle
	var forward_vec_scaled := forward*distance
	var left_vec_scaled := left*distance
	draw_line(startPos-forward_vec_scaled, startPos+forward_vec_scaled, mat)
	draw_line(startPos-left_vec_scaled, startPos+left_vec_scaled, mat)
	
	var step := 10
	if  distance > step:
		var disti := floori(distance)
		for i in range(maxi(step,(disti-(disti%step))-(step*10)),floori(distance),step):
			forward_vec_scaled = forward*i
			left_vec_scaled = left*i
			
			var fw_size := forward*(0.5*sqrt(i))
			var l_size := left*(0.5*sqrt(i))
			
			var fw_start_1 := startPos-forward_vec_scaled
			var fw_start_2 := startPos+forward_vec_scaled
			
			var l_start_1 := startPos-left_vec_scaled
			var l_start_2 := startPos+left_vec_scaled
			draw_line(fw_start_1-l_size, fw_start_1+l_size, mat2)
			draw_line(fw_start_2-l_size, fw_start_2+l_size, mat2)
			
			draw_line(l_start_1-fw_size, l_start_1+fw_size, mat2)
			draw_line(l_start_2-fw_size, l_start_2+fw_size, mat2)
	# draw the "cross" for easier orientation n shet
	
	draw_empty_circle(startPos,distance,distance_circle_resolution,mat)
	
	# empty triangle between circles and base
	draw_line_strip([startPos,heightPos,horizontalPos,startPos],mat2)
	
	draw_empty_circle(heightPos,circle_radius,circle_resolution,mat2)
	draw_empty_circle(horizontalPos,circle_radius,circle_resolution,mat2)
