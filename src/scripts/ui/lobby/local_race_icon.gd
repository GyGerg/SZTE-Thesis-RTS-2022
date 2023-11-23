extends NinePatchRect

var color_tween:Tween = null

func _on_local_player_loaded(player:PlayerData):
	player.race_changed.connect(func(_o,r): _on_race_changed(r))
	player.color_changed.connect(func(_o,c): _on_color_changed(c))

func _on_race_changed(race:Race):
	texture = race.icon
	
func _on_color_changed(color:Color):
	if color_tween:
		color_tween.kill()
	color_tween = create_tween()
	color_tween.tween_property(self, "modulate", color, 0.05)