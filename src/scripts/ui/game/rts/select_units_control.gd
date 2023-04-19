class_name SelectUnitsControlGD
extends Control


@onready var viewport := get_viewport()
@onready var cam := viewport.get_camera_3d()

const RAY_LENGTH := 1000
var drag_project_distance : float = .0
var dragging := false
var drag_start_global := Vector3.ZERO
var drag_start := Vector2.ZERO
var mouse_position := Vector2.ZERO

var selectable_units : Array

@onready var multi_mesh : MultiMesh = $MultiMeshInstance3D.multimesh

var selected_units : Array[Node3D] = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	if dragging:
		await _select_units()
	elif selected_units.size() > 0:
		_process_unit_circles()
			

func _process_unit_circles():
	for i in selected_units.size():
		if not selected_units[i]:
			continue
		multi_mesh.set_instance_transform(i, (selected_units[i] as Node3D).transform.translated_local(Vector3.DOWN*0.5))

func _draw():
	
	if !dragging:
		return
	drag_start = cam.unproject_position(drag_start_global)
	var start := drag_start
	var end := mouse_position
	if(start.x > end.x):
		var temp := start.x
		start.x = end.x
		end.x = temp
	if(start.y > end.y):
		var temp := start.y
		start.y = end.y
		end.y = temp
		
	var color := Color.GREEN
	var rect := Rect2(start,end-start)
	color.a = 0.3
	draw_rect(rect,color,false,2)
	color.a = 0.1
	draw_rect(rect,color,true)
	
func _input(event):
	if event is InputEventMouseMotion:
		var mouse_event := event as InputEventMouseMotion
		mouse_position = mouse_event.position
	if event is InputEventMouseButton:
		var btn_event := event as InputEventMouseButton
		
		if btn_event.button_index == MOUSE_BUTTON_LEFT:
			if btn_event.is_pressed() and not btn_event.is_echo():
#				print("setting drag start global")
				drag_start_global = cam.project_position(mouse_position, drag_project_distance)
				
			dragging = btn_event.is_echo() || btn_event.is_pressed()
			if dragging:
				drag_start = cam.unproject_position(drag_start_global)
#				print("drag start: ",drag_start)
#				print("drag start GLOBAL: ", drag_start_global)
			else:
				drag_start = Vector2.ZERO
#				print("drag finished, length of selected units: ", selected_units.size())
#			drag_start = mouse_position if dragging else Vector2.ZERO
	pass
	
func _select_units():
	var new_selected : Array[Node3D] = []
	if mouse_position.distance_squared_to(drag_start) < 16:
		var un := _try_get_unit_under_mouse_pos()
		if un:
			new_selected.append(un)
	else:
		var top_left := drag_start
		var bottom_right := mouse_position
		if top_left.x > bottom_right.x:
			var temp := top_left.x
			top_left.x = bottom_right.x
			bottom_right.x = temp
		if top_left.y > bottom_right.y:
			var temp := top_left.y
			top_left.y = bottom_right.y
			bottom_right.y = temp
			
		var rect : Rect2 = Rect2(top_left,bottom_right-top_left)
		
		
#		var selectedUnits: Array = get_tree().get_nodes_in_group(is_selected)
#		selectedUnits.make_read_only()
#		selectedUnits.get_typed_builtin()
		
#		print("length of selectables: ", len(selectable_units))
		new_selected = _loop_through_units(rect,new_selected)
#		var counter := 0
#		new_selected.resize(len(selectable_units))
#		for unit in selectable_units:
#			var unprojected : Vector2 = cam.unproject_position(unit.position)
#
#			if not rect.has_point(unprojected):
#				continue
#			multi_mesh.set_instance_transform(counter, (unit as Node3D).transform.translated_local(Vector3.DOWN*0.5))
#			new_selected[counter] = unit
#			counter+=1
#		new_selected.resize(counter)
		
#		multi_mesh.visible_instance_count = counter
		
	selected_units = new_selected
	return new_selected
	pass


func _loop_through_units(rect:Rect2, new_selected: Array):
	var counter := 0
	new_selected.resize(selectable_units.size())
	for unit in selectable_units:
		var unprojected : Vector2 = cam.unproject_position(unit.position)
		
		if not rect.has_point(unprojected):
			if unit.is_in_group("is_selected"):
				unit.remove_from_group("is_selected")
			continue
		if not unit.is_in_group("is_selected"):
			unit.add_to_group("is_selected")
			pass
		multi_mesh.set_instance_transform(counter, unit.transform.translated_local(Vector3.DOWN*0.5))
		new_selected[counter] = unit
		counter+=1
	new_selected.resize(counter)
	return new_selected
func _try_get_unit_under_mouse_pos() -> Node3D:
	var res := _ray_from_mouse(3)
	if res.has("collider"):
		print(typeof(res["collider"]))
		
		var node := res["collider"] as Node3D
		if node.has_node("Selectable"):
			print("node is selectable")
			return node
	return null
	
func _ray_from_mouse(collision_mask: int) -> Dictionary:
	var start := cam.project_ray_origin(mouse_position)
	var end := start + (cam.project_ray_normal(mouse_position)*RAY_LENGTH)
	var space_state := viewport.world_3d.direct_space_state
	
	return space_state.intersect_ray(PhysicsRayQueryParameters3D.create(start,end,collision_mask,[]))


func _on_camera_controller_distance_changed(new_distance:float):
	print("setting new distance")
	drag_project_distance = new_distance
	pass # Replace with function body.


func _on_node_3d_done_instancing():
	selectable_units = get_tree().get_nodes_in_group("units").filter(func(u): return u.has_node("Selectable"))
	selectable_units.hash()
	selectable_units.make_read_only()
	multi_mesh.instance_count = selectable_units.size()
	pass # Replace with function body.
