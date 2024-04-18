extends VBoxContainer

var hp: int
var mp: int
var is_dead: bool = false
var main_game_node

var char_data = {
	'char_name': 'char_name',
	'stats':{
		'max_hp': 100, 
		'max_mp': 100
	},
	'exp': 0.0,
	'gold': 0,
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

func set_char_data(data: Variant):
	char_data = data

func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')
	
	# TODO: set HP and MP from max HP and MP from JSON object
	hp = char_data.stats.max_hp
	$HP.max_value = char_data.stats.max_hp
	
	mp = char_data.stats.max_mp
	$MP.max_value = char_data.stats.max_mp
	
func _process(_delta):
	pass
		
func subtractHP(val):
	hp -= int(val)	
	var tween = get_tree().create_tween()
	tween.tween_property($HP, "value", hp, .25)

	if hp <= 0:
		hp = 0
		self.death()

func death():
	self.is_dead = true
	main_game_node.combat_log_append(self.char_data.char_name + ' has died.')
	$deathSound.play()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0.5), 2)
	await get_tree().create_timer(2.0).timeout
	$deathIcon.modulate = Color(1,1,1,2)
	$deathIcon.show()

func revive():
	$deathIcon.hide()
	$reviveSound.play()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,1), 2)
	
func addHP(val):
	hp += int(val)
	if hp >= char_data.stats.max_hp:
		hp = char_data.stats.max_hp
	if is_dead == true and hp > 0:
		is_dead = false
		revive()
		main_game_node.combat_log_append(self.char_data.char_name + ' has been revived.')
	var tween = get_tree().create_tween()
	tween.tween_property($HP, "value", hp, .25)
		
func subtractMP(val):
	mp -= int(val)	
	if mp <= 0:
		mp = 0
	var tween = get_tree().create_tween()
	tween.tween_property($MP, "value", mp, .25)
	
func addMP(val):
	mp += int(val)
	if mp >= char_data.stats.max_mp:
		mp = char_data.stats.max_mp
	var tween = get_tree().create_tween()
	tween.tween_property($MP, "value", mp, .25)
		
func _on_char_image_mouse_entered():
	$focused.show()
	UiSoundPlayer.get_node('buttonSoundHover').play()

func _on_char_image_mouse_exited():
	$focused.hide()
	
func take_damage(raw_damage):
	if not is_dead:
		$hurtSound.play()
		$charImage/AnimationPlayer.play('hurt')
		# do something to the raw_damage value before applying it
		var modified_damage = raw_damage
		subtractHP(modified_damage)
		main_game_node.combat_log_append(self.char_data.char_name + ' just took ' + str(modified_damage)+ ' damage.')

# PURELY FOR TESTING PURPOSES
func _on_char_image_gui_input(event):
	if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				take_damage(10)
				main_game_node.show_enemy_combat_chat_message('STOP TOUCHING ME CUCK!', preload('res://assets/DoomlandKit/Single-Characters/SpearHero4.png'))
			if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				addHP(25)
				main_game_node.show_enemy_combat_chat_message('Thanks for reviving me.', preload('res://assets/DoomlandKit/Single-Characters/SpearHero4.png'))
