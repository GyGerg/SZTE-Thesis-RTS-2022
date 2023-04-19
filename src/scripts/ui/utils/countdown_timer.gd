class_name CountdownTimer extends Node

signal second_passed(seconds_left:int)

var current_timer:SceneTreeTimer
var seconds_left:int
var interval:int
func _init(seconds:int,interval:int=1):
	seconds_left = seconds
# Called when the node enters the scene tree for the first time.
func _ready():
	current_timer = get_tree().create_timer(1)
	current_timer.timeout.connect(_on_timer_done, CONNECT_ONE_SHOT)
	pass # Replace with function body.

func _on_timer_done():
	seconds_left-=1
	second_passed.emit(seconds_left)
	if seconds_left == 0:
		queue_free()
	current_timer = get_tree().create_timer(1)
	current_timer.timeout.connect(_on_timer_done, CONNECT_ONE_SHOT)
	pass
