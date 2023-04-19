class_name PlayerData extends Node

signal race_changed(old_race:Race,new_race:Race)
signal color_changed(old_color:Race,new_color:Race)

signal setup_done()

const ReadyPrefab := preload("res://src/scenes/state/player/player_ready.tscn")

@export var _race_path:String : 
	set(val):
		
		if _race_path == val:
			return
		print("%s _race_path setter called" % str(multiplayer.get_remote_sender_id()))
		_race_path = val
		var loaded := load(_race_path)
		print("%s is loaded race null? " % str(multiplayer.get_remote_sender_id()), loaded == null)
		if loaded != null and loaded is Race:
			race = loaded
@export var race : Race = load(_race_path) if _race_path.length() > 0 else null :
	set(val):
		if (not val) or (race and val.name == race.name):
			return
		print("%s race setter called, is val null: " % str(multiplayer.get_remote_sender_id()), val == null)
		if val:
			var path := val.resource_path
			if _race_path != path:
				_race_path = path
		var old_race := race
		race = val
		race_changed.emit(old_race,race)

@export var color : Color :
	set(val):
		if val == color:
			return
		var old_color := color
		color = val
		color_changed.emit(old_color,color)
@export var player_id:int=1 :
	set(id):
		player_id = id
#		$MultiplayerSynchronizer.set_multiplayer_authority(id)
		
func _enter_tree():
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	var parent := get_parent() as PlayerManager
	print("%s -- player spawned with %s" % [str(multiplayer.get_unique_id()), str(player_id)])
	setup_done.emit()
#	get_tree().create_timer(0).timeout.connect(func(): 
#		self.set_multiplayer_authority(player_id))
	pass # Replace with function body.
