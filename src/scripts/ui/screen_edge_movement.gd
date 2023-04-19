class_name ScreenEdgeMovement extends Node3D

signal position_moved(difference: Vector2)
signal distance_changed(new_distance: float)

@onready var _camera_node := $Camera3D

@export_category("RTS Camera")

@export_group("Zoom Limits","zoom_")
@export_range(30,1000) var zoom_backward_limit := 30
@export_range(5.0,30) var zoom_forward_limit := 6.5

@export_range(15,200) var zoom_speed_multiplier := 1
@export_group("Scroll modifiers", "scroll_")
@export_range(0.1,50) var scroll_speed := 1.0


var _current_zoom_value := .0 :
	get:
		return _current_zoom_value
	set (value):
		if _current_zoom_value == value:
			return
		_current_zoom_value = clampf(value,zoom_forward_limit,zoom_backward_limit)
		distance_changed.emit(_current_zoom_value)
		
var _zoom_tween : Tween


var _viewport : Viewport
var _last_mouse_pos := Vector2.ZERO
var _last_scroll := 0
var _last_delta := .0

# Called when the node enters the scene tree for the first time.
func _ready():
	_viewport = get_viewport()
	_current_zoom_value = _camera_node.position.distance_to(position)
	print(_current_zoom_value)
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _zoom_delta_calculate(delta:float) -> float:
	return delta * zoom_speed_multiplier

func on_edge_move(input:Vector2,delta:float) -> void:
	if !delta:
		delta = _last_delta
	input *= scroll_speed
	
	var asd := ((transform.basis.x.normalized()*input.x) + (transform.basis.z.normalized()*input.y))
	asd.y = 0
	asd = asd.normalized()*input.length()
	translate(asd*_last_delta)
	pass

func _process(delta:float):
	_last_delta = delta
	pass

func _input(event):
	if event is InputEventMouseMotion:
		var mouseEvt := event as InputEventMouseMotion
		_last_mouse_pos = mouseEvt.position
		if mouseEvt.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			var rel := mouseEvt.relative
			print("middle mb mask")
			pass
	elif event is InputEventMouseButton:
		var mouseEvt := event as InputEventMouseButton
		if mouseEvt.is_action_pressed("scroll_action_any"):
			var strength := Input.get_axis("scroll_action_down", "scroll_action_up")
			if strength == 0:
				return
				
			var calced := _zoom_delta_calculate(_last_delta)
			calced = _current_zoom_value-(calced*strength)
			
			calced = clampf(calced, zoom_forward_limit, zoom_backward_limit)
			
			var difference := absf(_current_zoom_value-calced)*strength
			
			if difference == 0:
				return
			_current_zoom_value = calced
	#		_camera_node.translate(Vector3.BACK*difference)
			var new_transform : Transform3D = _camera_node.transform.translated_local(Vector3.FORWARD*difference)
			
			if _zoom_tween:
				_zoom_tween.kill()
			
			_zoom_tween = create_tween()
			_zoom_tween.set_ease(Tween.EASE_IN_OUT)
			_zoom_tween.tween_property(_camera_node, "position", new_transform.origin, _last_delta*8)
			_zoom_tween.tween_property(self, "_current_zoom_value", calced, _last_delta*8)
			_zoom_tween.play()
