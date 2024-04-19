extends VBoxContainer

var main_game_node
var rng = RandomNumberGenerator.new()

# default char_data data structure
var char_data = {
	'char_name': GlobalVars.generate_word(7),
	'char_texture': 'res://assets/DoomcryptKit/Single-Characters/' + GlobalVars.choose_random_from_list(GlobalVars.dir_contents("res://assets/DoomcryptKit/Single-Characters/")),
	'stats':{
		'max_hp': rng.randi_range(0, 200), 
		'max_mp': rng.randi_range(0, 200),
		'initiative': rng.randi_range(0, 6), # who goes first during turn based combat
		
		# How well you can resist damage to MP and HP
		'magic_resist': rng.randf_range(0, 1), # how well you can withstand magic attacks
		'physical_resist': rng.randf_range(0, 1), # how well you can withstand physical attacks
		
		# Status effect resistances (base determined by class)
		'plagued_resist': rng.randf_range(0, 1), # how well you can withstand plague attacks
		'burned_resist': rng.randf_range(0, 1),
		'poisoned_resist': rng.randf_range(0, 1)
	},
	'currents':{
		'hp': null,
		'mp': null,
		'plagued': rng.randf_range(0, 1.1), # for instant death mechanic
		'burned': rng.randf_range(0, 1.1), # for damage over time mechanic
		'poisoned': rng.randf_range(0, 1.1) # for skipping moves mechanic
	},
	'exp': 0.0,
	'gold': rng.randi_range(0, 1000),
	'is_dead': false,
	'moves': [{
		'move_id': 'move001',
		'move_name': 'basic_attack',
		'move_desc': 'A simple punch'
	}],
	'items': [{
		'item_id': 'item001',
		'item_name': 'Healing Potion',
		'item_desc': 'Heals your health.',
		'consumable': {
			'currents_adjust':{
				
			}
		},
		'equippable':{
			'equip_slot': 'head',
			'equipped': false,
			'stats_adjust':{
				
			}
		}
	}],
	'equipment':{
		'head': null,
		'body': null,
		'legs': null,
		'weapon': null,
		'talisman': null,
	}
}

# the two constructors for combatChars:
func set_char_data_from_enemy(enemy_name: String):
	char_data = GlobalVars.returnDocInList(GlobalVars.lore_data.enemies, 'char_name', enemy_name).duplicate(true)
func set_char_data_from_player():
	char_data = GlobalVars.player_data

func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')
	
	# set up stuff for the combat char
	$Name.text = char_data.char_name
	$charImage.texture = load(char_data.char_texture)
	
	#set HP and MP from max HP and MP
	char_data.currents.hp = char_data.stats.max_hp
	$HP.max_value = char_data.stats.max_hp
	$HP.value = char_data.currents.hp
	
	char_data.currents.mp = char_data.stats.max_mp
	$MP.max_value = char_data.stats.max_mp
	$MP.value = char_data.currents.mp
	
func _process(_delta):
	if char_data.currents.hp > 0:
		$deathIcon.hide()
		
	# show the status effects
	if self.char_data.currents.burned >= 1:
		$statusEffects/burned.show()
	else:
		$statusEffects/burned.hide()
	if self.char_data.currents.poisoned >= 1:
		$statusEffects/poisoned.show()
	else:
		$statusEffects/poisoned.hide()
	if self.char_data.currents.plagued >= 1:
		$statusEffects/plagued.show()
	else:
		$statusEffects/plagued.hide()
		
func subtractHP(val):
	char_data.currents.hp  -= int(val)	
	var tween = get_tree().create_tween()
	tween.tween_property($HP, "value", char_data.currents.hp, .25)

	if char_data.currents.hp <= 0:
		char_data.currents.hp = 0
		self.death()

func death():
	char_data.is_dead = true
	main_game_node.combat_log_append(self.char_data.char_name + ' has died.')
	$deathSound.play()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0.5), 1)
	await get_tree().create_timer(1.0).timeout
	$deathIcon.modulate = Color(1,1,1,2)
	$deathIcon.show()

func revive():
	$deathIcon.hide()
	$reviveSound.play()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,1), 2)
	
func addHP(val):
	char_data.currents.hp += int(val)
	if char_data.currents.hp >= char_data.stats.max_hp:
		char_data.currents.hp = char_data.stats.max_hp
	if char_data.is_dead == true and char_data.currents.hp > 0:
		char_data.is_dead = false
		revive()
		main_game_node.combat_log_append(self.char_data.char_name + ' has been revived.')
	var tween = get_tree().create_tween()
	tween.tween_property($HP, "value", char_data.currents.hp, .25)
		
func subtractMP(val):
	char_data.currents.mp -= int(val)	
	if char_data.currents.mp <= 0:
		char_data.currents.mp = 0
	var tween = get_tree().create_tween()
	tween.tween_property($MP, "value", char_data.currents.mp, .25)
	
func addMP(val):
	char_data.currents.mp += int(val)
	if char_data.currents.mp >= char_data.stats.max_mp:
		char_data.currents.mp = char_data.stats.max_mp
	var tween = get_tree().create_tween()
	tween.tween_property($MP, "value", char_data.currents.mp, .25)
		
func _on_char_image_mouse_entered():
	$focused.show()
	UiSoundPlayer.get_node('buttonSoundHover').play()

func _on_char_image_mouse_exited():
	$focused.hide()
	
func take_damage(damage_obj: Variant):
	if not char_data.is_dead:
		$hurtSound.play()
		$charImage/AnimationPlayer.play('hurt')
		# do something to the raw_damage value before applying it
		var modified_damage = damage_obj.physical_damage + damage_obj.magical_damage
		main_game_node.combat_log_append(self.char_data.char_name + ' just took ' + str(modified_damage)+ ' damage.')
		subtractHP(modified_damage)

func get_gold_on_death() -> int:
	return char_data.gold

func get_items_on_death() -> Array:
	return char_data.items.duplicate(true)
	
# PURELY FOR TESTING PURPOSES
func _on_char_image_gui_input(event):
	if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				take_damage({
					'physical_damage':10,
					'magical_damage':5,
				})
				main_game_node.show_enemy_combat_chat_message('STOP TOUCHING ME CUCK!', preload('res://assets/DoomlandKit/Single-Characters/SpearHero4.png'))
			if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				addHP(25)
				main_game_node.show_enemy_combat_chat_message('Thanks for reviving me.', preload('res://assets/DoomlandKit/Single-Characters/SpearHero4.png'))
