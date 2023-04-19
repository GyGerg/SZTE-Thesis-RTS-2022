class_name HeightCursorGD
extends Node3D


@export var current_position :Vector3 = Vector3.ZERO:
	set(val):
		current_position = val
		global_position = current_position
	get: 
		return current_position
@export var curr_height :float = 0.0:
	set(val):
		curr_height = val
		if not (sphere == null):
			sphere.position = -Vector3.UP * curr_height
	get:
		return curr_height
@export var height_sensitivity :float = 10.0
@onready var sphere := $mouseSphere
@onready var viewport : Viewport
@onready var cam : Camera3D
@onready var world : World3D

var _is_shift_pressed := false
# Called when the node enters the scene tree for the first time.
func _ready():
	viewport = get_viewport()
	cam = viewport.get_camera_3d()
	world = get_world_3d()
	var dict := _get_3d_mouse_position_flat(viewport.get_mouse_position())
	current_position = dict["position"] as Vector3
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _get_3d_mouse_position_flat(mouse_position: Vector2) -> Dictionary:
	var space_state = world.direct_space_state
	
	var from := cam.project_ray_origin(mouse_position)
	var to := cam.project_ray_normal(mouse_position) * 1000
	var params := PhysicsRayQueryParameters3D.create(from, to, 128)
	
	params.collide_with_areas = true
	params.collide_with_bodies = false
	
	return space_state.intersect_ray(params)

func _reset_state(pos: Vector3):
	current_position = pos
	curr_height = 0.0
	
func _input(event):
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		var rel := motion.relative
		
		var result := _get_3d_mouse_position_flat(motion.global_position)
		if result.has("position"):
			var new_pos := result["position"] as Vector3
			if _is_shift_pressed:
				var rel_y_percent = rel.y / viewport.get_visible_rect().size.y
				curr_height = curr_height - (rel_y_percent * height_sensitivity)
				current_position = Vector3(current_position.x,curr_height,current_position.z)
			else:
				current_position = Vector3(new_pos.x,curr_height,new_pos.z)
				
			pass
	elif event is InputEventKey:
		var key := event as InputEventKey
		if key.keycode == KEY_SHIFT and !key.echo:
			_is_shift_pressed = key.pressed
			Input.warp_mouse(cam.unproject_position(global_position))
