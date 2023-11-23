@tool
class_name PlayerListCard extends HBoxContainer

@export var icon_holder:NinePatchRect
@export var name_label:Label
@export var ready_icon:NinePatchRect

var tex:Texture2D
var player_data:PlayerData
# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		return
	print("not editor")
	icon_holder.size = Vector2(32,32)
	name_label.text = player_data.name
	
	change_color(player_data.color)
	if player_data.race:
		change_icon(player_data.race.icon)
	player_data.color_changed.connect(change_color_from_signal)
	player_data.race_changed.connect(change_race_from_signal)
	
	var player_manager := (GameState.get_node("Players") as PlayerManager)
	player_manager.player_ready_changed.connect(func(p:PlayerData):
		if player_data == p:
			_on_ready_change(p)
	)

	ready_icon.visible = player_data.player_id == 1 # server id is always 1
	pass # Replace with function body.

func _on_ready_change(player:PlayerData):
	if player != player_data:
		return
	var has_ready_node := PlayerReady.is_ready(player_data)
	print("Local player has ready node: ", has_ready_node)
	ready_icon.visible = has_ready_node

func change_color_from_signal(old_color:Color,color:Color):
	print("%s, change_color_from_signal called" % str(multiplayer.get_remote_sender_id()))
	change_color(color)

func change_race_from_signal(old_race:Race,race:Race):
	print("%s, change_race_from_signal called" % str(multiplayer.get_remote_sender_id()))
	if race != null:
		change_icon(race.icon)

func change_color(color:Color):
	icon_holder.modulate = color
func change_icon(icon:Texture2D):
	icon_holder.texture = icon


func _draw():
	draw_style_box(get_theme_stylebox("normal"), Rect2(Vector2.ZERO, get_rect().size))
	child_entered_tree.connect(func(x):
		if not x is TextureRect:
			return
		print("icon holder entered")
		var holder := x as TextureRect
		holder.draw_style_box(get_theme_stylebox("normal"),Rect2(Vector2.ZERO, holder.get_rect().size))
	)
