@tool
class_name UIUnitPreview extends UIIcon

@export_group("UI Elements", "ui_")
@export_subgroup("Unit Preview UI")
@export var ui_progress:HealthBar
@export var ui_unit_counter:Label

#@export var icon_container:TextureRect
@export_category("UI vars")
@export var _unit_count:int = 0:
	set(val):
		_unit_count=val
		ui_unit_counter.text = str(val)
		ui_unit_counter.visible = val > 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_units_selected(unitType, unitIcon:Texture2D, unitCount:int):
	ui_icon_container.texture = unitIcon
	_on_unit_counter_changed(unitCount)
	
func _on_unit_counter_changed(unitCount:int):
	_unit_count=unitCount
	
func _on_progress_bar_value_changed(value:float):
#	var point:float = value/float(progress.min_value+progress.max_value)
#	if progress.visible != (point < 1):
#		progress.visible = point < 1
#	if point < 1:
#		stylebox.modulate_color = gradient.sample(point)
#		progress.queue_redraw()
	pass # Replace with function body.
