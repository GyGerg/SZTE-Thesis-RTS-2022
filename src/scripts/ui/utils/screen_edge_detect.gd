class_name ScreenEdgeDetect extends Node

@export_range(50,150) var edge_size := 100
@export var edge_segments := 5

@onready var _viewport := get_viewport()

# whatever goes here
signal edge_detected(side: Vector2)
signal edge_detected_process(side:Vector2,delta:float)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _calculate_translation_vector_2d(direction:Vector2, input:float) -> Vector2:
	var segment_divider := edge_size / (edge_segments-1)
	var translateSpeed := edge_segments - (input/segment_divider)
	return direction*(translateSpeed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_inside_tree():
		return
	var mouse_pos := _viewport.get_mouse_position()
	var size := _viewport.get_visible_rect().size
	var translateVector := Vector2.ZERO
	
	if mouse_pos.x < edge_size:
		translateVector += _calculate_translation_vector_2d(Vector2.LEFT, mouse_pos.x)
	elif size.x - mouse_pos.x < edge_size:
		translateVector += _calculate_translation_vector_2d(Vector2.RIGHT, size.x-mouse_pos.x)
	if mouse_pos.y < edge_size:
		translateVector += _calculate_translation_vector_2d(Vector2.UP, mouse_pos.y)
	elif size.y - mouse_pos.y < edge_size:
		translateVector += _calculate_translation_vector_2d(Vector2.DOWN, size.y-mouse_pos.y)
		
	translateVector = translateVector.limit_length(edge_segments)
	
	if not translateVector == Vector2.ZERO:
		edge_detected.emit(translateVector)
		edge_detected_process.emit(translateVector,delta)
	pass
