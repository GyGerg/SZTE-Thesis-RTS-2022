class_name MainMenu extends Control


signal on_peer_created()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_sp_click():
	create_server(1)
	_turn_off()

func _on_mp_click():
	create_client()
	_turn_off()

func _on_server_click():
	create_server(4)
	_turn_off()

func _turn_off():
	visible = false
	set_process(PROCESS_MODE_DISABLED)
	
func _turn_on():
	visible = true
	set_process(PROCESS_MODE_INHERIT)

func create_server(player_count:=1) -> void:
	var peer := MpManager.start_server(player_count)
	on_peer_created.emit()
	
func create_client(ip:String="localhost") -> void:
	var peer := MpManager.start_client(ip)
	on_peer_created.emit()
