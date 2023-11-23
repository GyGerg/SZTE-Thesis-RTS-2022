class_name RaceSelector extends OptionButton


@onready var pickable_races : Array[Race]
@export_dir var _dir_name:String

func _load_races():
	pickable_races = []
	self.clear()
	var dir := DirAccess.open(_dir_name)
	if dir:
		for file_name in dir.get_files():
			if not file_name.ends_with(".tres"):
				continue
			var res := load(_dir_name+"/"+file_name) as Race
			if res == null:
				continue
				
			pickable_races.append(res)
			_add_race_to_list(res)
	pass
	
func _add_race_to_list(race:Race):
	var inner_popup := get_popup()
	var i := item_count
	add_item(race.name)
	inner_popup.set_item_as_radio_checkable(i,false)
# Called when the node enters the scene tree for the first time.
func _ready():
	_load_races()
	pass # Replace with function body.

func _on_match_wait_started():
	disabled = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
