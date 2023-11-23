class_name CameraManagerRTS extends Control

@export var rts_cam : ScreenEdgeMovement
@export var minimap_cam : TopdownCameraMovement
@export var minimap_viewport : Viewport
@export var rts_multimesh : MultiMeshInstance3D
@export var minimap_multimesh_instance : MultiMeshInstance3D

@export var match_data : Match

func get_planets() -> Dictionary:
	return match_data.map_data.game_planets
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_map_loaded():
	var multimesh := minimap_multimesh_instance.multimesh
	var player_manager := (GameState.get_node("Players") as PlayerManager)
	
	var planet_sum := 0
	var all_planets : Array = []
	for arr in get_planets().values():
		all_planets.append_array(arr)
		
	multimesh.instance_count = all_planets.size()
	print("MINIMAP -- %s -- all planets count: %s" % [multiplayer.get_unique_id(),all_planets.size()])
	var game_planets := get_planets()
	for key in game_planets:
		var custom_color : Color = (Color.WHITE 
			if key == "unoccupied" else (player_manager.players[key].color 
				if player_manager.players[key] != player_manager.local_player 
				else Color.LIME_GREEN))
		print(custom_color)
		for planet in game_planets[key]:
			multimesh.set_instance_transform(
				planet_sum, Transform3D(Basis(), (planet as Planet).position).scaled_local(Vector3.ONE*(6 if key == "unoccupied" else 30))
			)
			multimesh.set_instance_color(planet_sum, custom_color)
			multimesh.set_instance_custom_data(planet_sum, custom_color)
			planet_sum += 1
#	multimesh.instance_count = planet_sum+1
	minimap_multimesh_instance.global_position = rts_multimesh.global_position

@rpc("authority")
func _on_move_cam_coords_received(coords:Vector2):
	rts_cam.position = Vector3(coords.x,0,coords.y)
	
func viewportEntered():
	var cnt = minimap_viewport.get_parent() as Control
	cnt.grab_focus()
func viewportExit():
	var cnt = minimap_viewport.get_parent() as Control
	cnt.release_focus()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
