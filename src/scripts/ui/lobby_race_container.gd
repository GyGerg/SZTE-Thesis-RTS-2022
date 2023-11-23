class_name LobbyLocalRaceContainer extends Control

@onready var player_manager : PlayerManager = GameState.get_node("Players")
@export var icon_holder : NinePatchRect
@export var description_label : Label
@export var bonuses_label : Label

var desc_tween:Tween = null
var color_tween:Tween = null
# Called when the node enters the scene tree for the first time.
func _ready():
	while player_manager.local_player == null:
		await player_manager.player_spawned
	
	var p := player_manager.local_player
	p.race_changed.connect(func(_o,r):_change_local_race(r))
	p.color_changed.connect(func(_o,c):_change_local_color(c))
	
	_change_local_color(p.color)
	while p.race == null:
		await p.race_changed
	_change_local_race(p.race)
	
	pass # Replace with function body.
	
func _animate_description(text:String):
	if desc_tween:
		desc_tween.kill()
	desc_tween = description_label.create_tween()
	description_label.visible_characters=0
	desc_tween.tween_property(description_label,"visible_characters", text.length(), text.length() * 0.03)

func _change_local_race(race:Race):
	icon_holder.texture = race.icon
	description_label.text = race.description
	
	_animate_description(race.description)
		
	pass
	
func _change_local_color(color:Color):
	if color_tween:
			color_tween.kill()
	color_tween = icon_holder.create_tween()
	color_tween.tween_property(icon_holder, "modulate", color, 0.05)
	pass
	
