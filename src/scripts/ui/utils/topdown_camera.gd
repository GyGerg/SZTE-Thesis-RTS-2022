class_name TopdownCameraMovement extends Node3D

signal minimap_click_at(pos:Vector2)

@onready var _max_size := _camera.size
var zoom_enabled := false
var _last_delta := .0

@export var _camera : Camera3D
@onready var _viewport := get_viewport()
# Called when the node enters the scene tree for the first time.
func _ready():
	global_position.y = _camera.size

func _process(delta):
	var mouse_pos := _viewport.get_mouse_position()
	var rect := _viewport.get_visible_rect()
	if not rect.has_point(mouse_pos):
		return
		
	if Input.is_action_pressed("left_click"):
		var orig := _camera.project_ray_origin(mouse_pos)
		var tgt := _camera.project_ray_normal(mouse_pos) * _camera.size
		var cursorPos = Plane(Vector3.UP, 0).intersects_ray(orig,tgt)
		if cursorPos != null:
			minimap_click_at.emit(Vector2(cursorPos.x,cursorPos.z))
	if Input.is_action_pressed("middle_click"):
		var last_velocity := Input.get_last_mouse_velocity()
		translate(Vector3(-last_velocity.x*delta,last_velocity.y*delta,0))
		pass
	
	var half_max_size := _max_size / 2
	var half_size := _camera.size / 2 
	var clamped_position := Vector3(
		clampf(global_position.x, -(half_max_size)+(half_size), (half_max_size)-(half_size)),
		global_position.y,
		clampf(global_position.z, -(half_max_size)+(half_size), (half_max_size)-(half_size))
	)
	global_position = clamped_position
	_last_delta = delta
	pass
	
var _zoom_tween : Tween
var _zoom_forward_limit := 250
@onready var _zoom_backward_limit := _camera.size

@export_range(15,5000) var zoom_speed_multiplier := 1

@onready var _current_zoom_value := _camera.size

func _unhandled_input(event):
#	if event.is_action_pressed("left_click"):
#		var mouse_pos := (event as InputEventMouseButton).position
#		var orig := _camera.project_ray_origin(mouse_pos)
#		var tgt := _camera.project_ray_normal(mouse_pos) * _camera.size
#		var cursorPos = Plane(Vector3.UP, 0).intersects_ray(orig,tgt)
#		if cursorPos != null:
#			minimap_click_at.emit(Vector2(cursorPos.x,cursorPos.z))
	if event is InputEventMouseButton:
		if event.is_action_pressed("scroll_action_any"):
			_viewport.set_input_as_handled()
#			var strength := 1 if Input.is_action_just_released("scroll_action_up") else -1
			var strength := Input.get_axis("scroll_action_down", "scroll_action_up")
			if strength == 0:
				return
				
			var calced := _zoom_delta_calculate(_last_delta)
			calced = _current_zoom_value-(calced*strength)
			
			calced = clampf(calced, _zoom_forward_limit, _zoom_backward_limit)
			print(calced)
			
			var difference := absf(_current_zoom_value-calced)*strength
			
			if difference == 0:
				return
			if _camera.projection == Camera3D.PROJECTION_PERSPECTIVE:
	#				_current_zoom_value = calced
				_camera.translate(Vector3.BACK*difference)

			if _zoom_tween:
				_zoom_tween.kill()
			
			_zoom_tween = create_tween()
			_zoom_tween.set_ease(Tween.EASE_IN_OUT)
			if calced < _current_zoom_value:
				var projected_pos := _camera.project_position(_viewport.get_mouse_position(), _camera.size)
				projected_pos.y = global_position.y
				var mult := minf(projected_pos.distance_to(global_position), _max_size/10)
				_zoom_tween.tween_property(_camera, "position", global_position+(global_position.direction_to(projected_pos)*mult), _last_delta*8)
			_zoom_tween.parallel().tween_property(_camera, "size", calced, _last_delta*8)
			_zoom_tween.parallel().tween_property(_camera, "_current_zoom_value", calced, _last_delta*8)
			_zoom_tween.play()
#			print(event)
func _zoom_delta_calculate(delta:float) -> float:
	return delta * (zoom_speed_multiplier * 2)
	
func _on_map_size_calculated(map_axis_size):
	_camera.size = map_axis_size
	_max_size = map_axis_size
	pass # Replace with function body.
