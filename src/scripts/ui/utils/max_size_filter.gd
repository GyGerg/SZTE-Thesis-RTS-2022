@tool
class_name ControlMaxSize extends Node


@onready var parent := get_parent() as Control
@export var limits : Vector2 = Vector2(32,32):
	set(val):
		val.x = maxf(val.x,0)
		val.y = maxf(val.y,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	if not parent:
		print("parent is not control")
		set_process(false)
	_limit_size()
	parent.resized.connect(_limit_size)
	pass # Replace with function body.

func _limit_size():
	print("limiting size of ", parent.name)
	parent.size = parent.size.clamp(Vector2.ZERO,Vector2(32,32))
	parent.queue_redraw()
