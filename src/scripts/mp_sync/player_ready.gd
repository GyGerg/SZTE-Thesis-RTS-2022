class_name PlayerReady extends Node
## tag component instead of keeping one(1) bool inside a class
const Prefab := preload("res://src/scenes/state/player/player_ready.tscn")

static func is_ready(player:PlayerData) -> bool:
	if not player:
		return false
	return player.has_node("PlayerReady") && !player.get_node("PlayerReady").is_queued_for_deletion()

static func get_ready_component(player:PlayerData) -> PlayerReady:
	return player.get_node("PlayerReady")

## returns the new ready state as a bool
static func change_ready_for(player:PlayerData) -> bool:
	var has_ready_node := is_ready(player)
	# print("CLIENT: player %s has ready node: %s" % [MpManager.multiplayer.get_remote_sender_id(),has_ready_node])
	if has_ready_node:
		var chld := player.get_node("PlayerReady")
		player.remove_child(chld)
		chld.queue_free()
		await chld.tree_exited
		return false
	else:
		var inst : PlayerReady = Prefab.instantiate()
		player.add_child(inst)
		return true
