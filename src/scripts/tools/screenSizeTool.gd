@tool
extends Node2D

@export_color_no_alpha var default_edge_color : Color = Color.AQUAMARINE : 
	set(val):
		if val != default_edge_color:
			notify_property_list_changed()
		default_edge_color = val
@export var colors : Array[Color] :
	set(arr):
		if arr != colors:
			var arrsize := arr.size()
			var colorsize := colors.size()
			if arrsize != colorsize:
				print("colors size changed, isEditor: %s" % [Engine.is_editor_hint()])
				print("colors: %s | arr: %s" % [colors.size(), arr.size()])
				if arrsize > colorsize:
					for i in range(colorsize, arrsize):
						var color := default_edge_color if not arr[i] else arr[i]
						print("setting %sth color as %s" % [i, color])
						arr[i] = color
			for i in mini(arrsize,colorsize):
				if colors[i] != arr[i]:
					print("color %s changed, isEditor: %s" % [i, Engine.is_editor_hint()])
			colors = arr
			notify_property_list_changed()

@export var edge_size : int = 100 :
	set(val):
		if val != edge_size:
			print("new edge size, isEditor: %s" % [Engine.is_editor_hint()])
			edge_size = val
			
			notify_property_list_changed()
@export var proba : ProbaKiirat
@export var racse : ProbaRacse
func _init():
	property_list_changed.connect(queue_redraw)
# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.is_editor_hint():
		($ProbaKiirat as ProbaKiirat).Kiir()
		var edge_detect = $EdgeDetect as ScreenEdgeDetect
		edge_detect.edge_segments = colors.size()
		edge_detect.edge_size = edge_size
		edge_detect.edge_detected.connect(func(x): print("edge detected: ",x))
	queue_redraw()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !Engine.is_editor_hint():
		return
	pass
	
func draw_rect_pre(rect:Rect2, color:Color):
	draw_rect(rect, color, false)
func _draw():
	if not Engine.is_editor_hint():
		var rect := get_viewport().get_visible_rect()
		var middle = rect.size/2
		draw_circle(Vector2(middle.x-50, middle.y+20), 50, Color.BURLYWOOD)
		draw_circle(Vector2(middle.x+50, middle.y+20), 50, Color.BURLYWOOD)
		draw_rect(Rect2(Vector2(middle.x-30, middle.y-70), Vector2(60, 100)), Color.BURLYWOOD)
		draw_circle(Vector2(middle.x, middle.y-80), 35, Color.BURLYWOOD)
	print("this shit should draw")
	draw_circle(get_viewport().get_visible_rect().size/2, 20, default_edge_color)
	
	var num_of_edges := colors.size()
	var size_divided := edge_size / num_of_edges
	var viewport_rect := get_viewport().get_visible_rect()
	for i in num_of_edges:
		var border_height := viewport_rect.size.y - (size_divided * (i*2))
		var border_width := viewport_rect.size.x - (size_divided * (i*2))
		
		var left_top := Vector2.ONE* (size_divided * i)
		var right_bottom := viewport_rect.size - Vector2.ONE*(size_divided*(i))
		var leftEdge := Rect2(Vector2.ONE*left_top, Vector2(size_divided, border_height))
		var rightEdge := Rect2(right_bottom.x,left_top.y, 
			-size_divided, border_height)
		var topEdge := Rect2(left_top, Vector2(border_width, size_divided))
		var bottomEdge := Rect2(left_top.x, right_bottom.y,border_width, -size_divided)
		
		var draw_color := colors[colors.size() - (i+1)]
		draw_rect_pre(leftEdge, draw_color)
		draw_rect_pre(rightEdge, draw_color)
		draw_rect_pre(topEdge, draw_color)
		draw_rect_pre(bottomEdge, draw_color)
	pass
