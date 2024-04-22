extends VBoxContainer

var main_game_node
var rng = RandomNumberGenerator.new()
var turn_active: bool = false

# default char_data data structure
var char_data = {
	'char_name': GlobalVars.generate_word(7),
	'char_texture': 'res://assets/DoomcryptKit/Single-Characters/' + GlobalVars.choose_random_from_list(GlobalVars.dir_contents("res://assets/DoomcryptKit/Single-Characters/")),
	'stats':{
		'max_hp': rng.randi_range(0, 200), 
		'max_mp': rng.randi_range(0, 200),
		'initiative': rng.randi_range(0, 10), # who goes first during turn based combat
		
		# How well you can resist damage to MP and HP
		'magic_resist': rng.randf_range(0, 1), # how well you can withstand magic attacks
		'physical_resist': rng.randf_range(0, 1), # how well you can withstand physical attacks
		
		# Status effect resistances (base determined by class)
		'plagued_resist': rng.randf_range(0, 25), # how well you can withstand plague attacks
		'burned_resist': rng.randf_range(0, 25),
		'poisoned_resist': rng.randf_range(0, 25)
	},
	'currents':{
		'hp': null,
		'mp': null,
		'plagued': rng.randf_range(0, .5), # for instant death mechanic
		'burned': rng.randf_range(0, .5), # for damage over time mechanic
		'poisoned': rng.randf_range(0, .5) # for skipping moves mechanic
	},
	'exp': 0.0,
	'gold': rng.randi_range(0, 1000),
	'is_dead': false,
	'is_paralyzed': false,
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
	if not char_data.is_dead:
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
	if not char_data.is_dead:
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
	#set_turn_active(true)
	UiSoundPlayer.get_node('buttonSoundHover').play()

func _on_char_image_mouse_exited():
	#set_turn_active(false)
	$focused.hide()
	
func set_turn_active(given_bool):
	if turn_active == given_bool:
		# play no animation and don't change anything
		pass
	else:
		turn_active = given_bool
		if 	turn_active:
			$AnimationPlayer2.play('pop_out')
		else:
			$AnimationPlayer2.play('pop_in')
	
func take_damage(damage_obj: Variant):
	if not char_data.is_dead:
		$hurtSound.play()
		$charImage/AnimationPlayer.play('hurt')
		# do something to the damage_obj values before applying it
		var modified_damage_obj = damage_obj
		main_game_node.combat_log_append(self.char_data.char_name + ' just took ' + str(abs(modified_damage_obj.hp)) + ' physical damage.')
		subtractHP(modified_damage_obj.hp)
		subtractMP(modified_damage_obj.mp)
		addStatusEffect('plagued', modified_damage_obj.plagued)
		addStatusEffect('poisoned', modified_damage_obj.poisoned)
		addStatusEffect('burned', modified_damage_obj.burned)

func addStatusEffect(status_name, value):
	# status effect buildup is mitigated by resitances
	var old_buildup = self.char_data.currents[status_name]
	self.char_data.currents[status_name] += (value - value*self.char_data.stats[status_name +'_resist']/100)
	if self.char_data.currents[status_name] >= 1 and old_buildup < 1:
		main_game_node.combat_log_append(self.char_data.char_name + ' is ' + status_name +'.')

# if any statuses are greater than 1, will apply them
func applyStatusEffects():
	# instant death
	if self.char_data.currents.plagued >= 1 and not self.char_data.is_dead:
		subtractHP(self.char_data.currents.hp)
	# burned loses 10 percent of health 
	if self.char_data.currents.burned >= 1:
		subtractHP(self.char_data.stats.max_hp * 0.10)
	# paralyze patient
	if self.char_data.currents.poisoned >= 1:
		self.char_data.is_paralyzed = true
	else:
		self.char_data.is_paralyzed = false
			
	# perform status cooldowns
	self.char_data.currents.poisoned -= 0.01 * self.char_data.stats.poisoned_resist/100.0
	self.char_data.currents.burned -= 0.01 * self.char_data.stats.burned_resist/100.0
	self.char_data.currents.plagued -= 0.01 * self.char_data.stats.plagued_resist/100.0
	
func get_gold_on_death() -> int:
	return char_data.gold

func get_items_on_death() -> Array:
	return char_data.items.duplicate(true)
	
# animate the health bar to transition colors
func _on_hp_value_changed(value):
	var percent = value / float($HP.max_value)
	$HP["theme_override_styles/fill"].bg_color = Color(1,0,0).lerp(Color(0,1,0), percent)
	
# PURELY FOR TESTING PURPOSES
func _on_char_image_gui_input(event):
	if event is InputEventMouseButton and main_game_node.engine.playerTurn:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				take_damage({
					'hp':10,
					'mp':5,
					'plagued': 0.20,
					'poisoned': 0.30,
					'burned': 0.30
				})
				main_game_node.show_enemy_combat_chat_message('STOP TOUCHING ME CUCK!', preload('res://assets/DoomlandKit/Single-Characters/SpearHero4.png'))
				
			if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				addHP(25)
				main_game_node.show_enemy_combat_chat_message('Thanks for reviving me.', preload('res://assets/DoomlandKit/Single-Characters/SpearHero4.png'))
				
				
