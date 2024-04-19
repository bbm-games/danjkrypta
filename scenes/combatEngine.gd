#class definition:
class_name CombatEngine
# Inheritance:
extends Node

var main_game_node
var rng = RandomNumberGenerator.new()

static var MAX_PARTY_SIZE = 4

# Constructor
func _init(main_game_node_given, enemy_names = []):
	# establish nodes and stuff
	main_game_node = main_game_node_given
	var playerPartyNode = main_game_node.get_node('gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/playerParty/roster/')
	var enemyPartyNode = main_game_node.get_node('gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/enemyParty/roster/')

	print("Initiated turn-based combat engine.")
	
	# clear the existing combat UI combatChars
	deleteChildNodes(playerPartyNode)
	deleteChildNodes(enemyPartyNode)
	
	# always first add the player to the playerParty
	var scene = preload("res://scenes/combatChar.tscn")
	var instance = scene.instantiate()
	instance.set_char_data_from_player()
	playerPartyNode.add_child(instance)
	
	#TODO: add any other player party members
	
	# create a default enemy party if none are provided
	if enemy_names.is_empty():
		for i in range(MAX_PARTY_SIZE - 1):
			scene = preload("res://scenes/combatChar.tscn")
			instance = scene.instantiate()
			enemyPartyNode.add_child(instance)
	else:
		for enemy_name in enemy_names:
			scene = preload("res://scenes/combatChar.tscn")
			instance = scene.instantiate()
			instance.set_char_data_from_enemy(enemy_name)
			enemyPartyNode.add_child(instance)

func deleteChildNodes(node: Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
