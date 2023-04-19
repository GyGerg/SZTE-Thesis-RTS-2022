class_name ColorSelector extends OptionButton

@onready var inner_popup := get_popup()
@export var pickable_colors:Array[Color]
# Called when the node enters the scene tree for the first time.
func _ready():
	populate_with_colors(pickable_colors)
	pass # Replace with function body.

func populate_with_colors(colors:Array[Color]) -> void:
	clear()
	var i := 0
	for color in pickable_colors:
		add_color_item(color)
		inner_popup.set_item_as_radio_checkable(i,false)
		i+=1
	
func _get_color_texture(color:Color) -> GradientTexture2D:
	var new_texture := GradientTexture2D.new()
	new_texture.gradient = Gradient.new()
	new_texture.gradient.set_color(0,color)
	new_texture.gradient.remove_point(1)
	new_texture.width = 24
	new_texture.height = 24
	return new_texture


func add_color_item(color:Color) -> void:
	add_icon_item(_get_color_texture(color),"")
	inner_popup.set_item_as_radio_checkable(item_count-1,false)
