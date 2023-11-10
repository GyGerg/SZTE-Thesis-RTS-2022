@tool
class_name HealthBar extends Range

@export var gradient : Gradient
@export var visible_on_full : bool = false
@onready var stylebox := get_theme_stylebox("fill") if not Engine.is_editor_hint() else null

### IMPORTANT: copy-paste the colorPath value
@export var colorPath:String
#	set(path):
#		if not (get(path) is Color):
#			printerr("Provided path is not a color!")
#		else:
#			colorPath = path

func _value_changed(new_value:float):
	var point:float = new_value/float(min_value+max_value)
	if !visible_on_full && visible != (point < 1):
		visible = point > 0 && (visible_on_full || point < 1)
	if visible_on_full || point < 1:
		pass
		self.set(colorPath, gradient.sample(point))
#		var style := stylebox if not Engine.is_editor_hint() else get_theme_stylebox("fill").modulate_color
#		style.modulate_color = gradient.sample(point)
#	super._value_changed(new_value)
		
