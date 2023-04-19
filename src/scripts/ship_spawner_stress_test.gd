extends Node3D

@export var prefab := preload("res://src/scenes/trial_ship.tscn")

signal done_instancing()
@export_range(1,3) var spread := 1.5

@export_range(1,30) var dim_size:=10 
# Called when the node enters the scene tree for the first time.
func _ready():
	var units := get_parent().get_node("Units")
	for child in units.get_children():
		child.queue_free()
	for x in dim_size:
		for y in dim_size:
			for z in dim_size:
				var ship := prefab.instantiate()
				$Children.add_child(ship)
				ship.position = position+Vector3(x*spread-(dim_size*spread)/2,y*spread-(dim_size*spread)/2,z*spread-(dim_size*spread)/2)
	await get_tree().create_timer(0).timeout
	done_instancing.emit()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
