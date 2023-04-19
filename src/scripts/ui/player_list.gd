class_name PlayerList extends VBoxContainer

@onready var child_cards : Array[PlayerListCard] = []
@onready var players_node : PlayerManager = GameState.get_node("Players")

@export var player_card : PackedScene = load("res://src/scenes/ui/player_list_card.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	for player in players_node.players.values():
		_on_player_join(player)
	players_node.player_spawned.connect(_on_player_join)
	players_node.player_leaving.connect(_on_player_leaving)
	pass # Replace with function body.

func _on_player_join(player:PlayerData):
	var new_card := player_card.instantiate() as PlayerListCard
	new_card.player_data = player
	new_card.name = "PlayerCard--%s" % str(player.player_id)
	child_cards.append(new_card)
	# todo: stuff
	add_child(new_card)
	
	pass

func get_card_for_player(player:PlayerData) -> PlayerListCard:
	return _get_card_by_player_idx(player.player_id)
	
func _get_card_by_player_idx(player_id:int) -> PlayerListCard:
	for card in child_cards:
		if card.player_data.player_id == player_id:
			return card
	return null

func _on_player_leaving(player:PlayerData):
	var filtered := child_cards.filter(func(x:PlayerListCard):return x.player_data.player_id == player.player_id)
	remove_child(filtered[0])
	child_cards.remove_at(child_cards.find(filtered[0]))
	filtered[0].queue_free()
	pass
	
