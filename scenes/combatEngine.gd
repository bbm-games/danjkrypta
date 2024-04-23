#class definition:
class_name CombatEngine

# Inheritance:
extends Node

var main_game_node
var rng = RandomNumberGenerator.new()

var playerTurn: bool = false
var playerPartyNode: Node
var enemyPartyNode: Node
var players = []
var players_sorted_by_turn = [] # highest initiative roll to lowest
var current_sorted_players_index = -1

static var MAX_PARTY_SIZE = 4

# Constructor
func _init(main_game_node_given, enemy_names = []):
	# establish nodes and stuff
	main_game_node = main_game_node_given
	playerPartyNode = main_game_node.get_node('gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/playerParty/roster/')
	enemyPartyNode = main_game_node.get_node('gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/enemyParty/roster/')
	
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
		for i in range(MAX_PARTY_SIZE):
			scene = preload("res://scenes/combatChar.tscn")
			instance = scene.instantiate()
			instance.set_char_data_from_enemy('default_enemy001')
			enemyPartyNode.add_child(instance)
	else:
		for enemy_name in enemy_names:
			scene = preload("res://scenes/combatChar.tscn")
			instance = scene.instantiate()
			instance.set_char_data_from_enemy(enemy_name)
			enemyPartyNode.add_child(instance)
			
	# create a list of all players in the game
	players = playerPartyNode.get_children() + enemyPartyNode.get_children()
	
	# now set the turn order
	setTurnOrder()

func nextTurn():
	current_sorted_players_index += 1
	if current_sorted_players_index >= players.size():
		current_sorted_players_index = 0
	var current_player = players_sorted_by_turn[current_sorted_players_index]
	# apply any status effects players are experiencing and make them not pop out
	for player in players:
		player.applyStatusEffects()
		player.set_turn_active(false)
		
	# make the current player pop out
	current_player.set_turn_active(true)
	
	if current_player == playerPartyNode.get_children()[0]:
		self.playerTurn = true
		main_game_node.updateStatsTab()
	# if the current player is dead or paralyzed skip them
	elif current_player.char_data.is_dead or current_player.char_data.is_paralyzed:
		self.playerTurn = false
		await main_game_node.get_tree().create_timer(1).timeout
		main_game_node.updateStatsTab()
		main_game_node.engine.nextTurn()
	else:
		self.playerTurn = false
		# DO SOME AI SHIT FOR THE NPCs HERE
		await main_game_node.get_tree().create_timer(3).timeout
		main_game_node.updateStatsTab()
		main_game_node.engine.nextTurn()
	
		
# determines who goes when based on initiative
func setTurnOrder():
	var checks = []
	for player in players:
		checks.append({'obj': player, 'initiative': d20() + int(player.char_data.stats.initiative)})
	checks.sort_custom(func(a, b): return a.initiative > b.initiative)
	for check in checks:
		players_sorted_by_turn.append(check.obj)
	
func deleteChildNodes(node: Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func d20():
	return rng.randi_range(1,20)
