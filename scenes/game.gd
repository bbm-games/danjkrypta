extends Node2D

var lorem = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
var player_data = {'posX': 0, 'posY': 0} # some default shit to initialize to
var party = [] # contains the char data for party members
var tweens = []
var player_menu_on_screen = false
var text_done_showing_counter = 0

var walk_up_held = false
var walk_down_held = false
var walk_left_held = false
var walk_right_held = false
var partyLeaderPositionBuffer = []

static var CONSOLE_TAB_INDEX = 4
static var COMBAT_TAB_INDEX = 3

var engine: CombatEngine
var in_combat = false : set = _set_in_combat;
func _set_in_combat(val):
	in_combat = val
	if in_combat:
		$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer.set_tab_hidden(COMBAT_TAB_INDEX, false)
	else:
		$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer.set_tab_hidden(COMBAT_TAB_INDEX, true)

var next_layer_after_loading = null

func _ready():
	# hide all shit
	hideAllLayers()
	
	# show the menu screen first
	$menuLayer.show()
	
func startCombat():
	# show the player menu (which doubles as combat screen)
	$gameLayer/HUDLayer/playerMenu/AnimationPlayer.play('slide_up')
	player_menu_on_screen = true
	# set the boolean to be in combat (disable walking and playerMenu closing with ESC key and stuff)
	_set_in_combat(true)
	# make the combat tab on the menu clickable
	engine = CombatEngine.new(self)
	
	# start the game loop
	engine.nextTurn()
			
func endCombat():
	_set_in_combat(false)
	
func combat_log_clear():
	$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/playerParty/combatLog.clear()

func combat_log_append(text_given: String):
	$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/playerParty/combatLog.newline()
	$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/playerParty/combatLog.append_text(text_given)

func _on_button_4_pressed():
	get_tree().quit()
	
func _process(delta):
	if $menuLayer.visible:
		$battleMusicPlayer.stop()
		if not $backgroundMusicPlayer.is_playing():
			$backgroundMusicPlayer.play()
			
	if $gameLayer.visible:
		#$gameLayer/partyMembers/CharacterBody2D.position = $gameLayer/partyMembers/CharacterBody2D.position.lerp(Vector2(player_data.posX, player_data.posY) * 16, delta*10)
		if in_combat:
			$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay.show()
			$backgroundMusicPlayer.stop()
			if not $battleMusicPlayer.playing:
				$battleMusicPlayer.play()
			
		else:
			if not $backgroundMusicPlayer.playing:
				$backgroundMusicPlayer.play()
			$battleMusicPlayer.stop()
			$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay.hide()
			'if Input.is_action_pressed("move_up"):
				player_data.posY -= (1.0/20)
			elif Input.is_action_pressed("move_down"):
				player_data.posY += (1.0/20)
			elif Input.is_action_pressed("move_left"):
				player_data.posX -= (1.0/20)
			elif Input.is_action_pressed("move_right"):
				player_data.posX += (1.0/20)'
	if $loadingLayer.visible:
		if $loadingLayer/Panel/RichTextLabel.visible_ratio >= 1:
			text_done_showing_counter += delta
	else:
		text_done_showing_counter = 0
		
func _input(event):
	# toggle the console
	if event.is_action_pressed('console'):
		$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer.set_tab_hidden(CONSOLE_TAB_INDEX, not $gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer.is_tab_hidden(CONSOLE_TAB_INDEX))
	if $loadingLayer.visible:
		if Input.is_anything_pressed() and $loadingLayer/Panel/RichTextLabel.visible_ratio < 1:
			for tween in tweens:
				tween.stop()
			$loadingLayer/Panel/RichTextLabel.visible_ratio = 1
		if Input.is_anything_pressed() and $loadingLayer/Panel/RichTextLabel.visible_ratio == 1 and text_done_showing_counter > 0.25:
			hideAllLayers()
			text_done_showing_counter = 0
			next_layer_after_loading.show()
		
	if $gameLayer.visible and not in_combat:
		if event.is_action_pressed('menu'):
			if player_menu_on_screen:
				$gameLayer/HUDLayer/playerMenu/AnimationPlayer.play('slide_down')
				player_menu_on_screen = false
				UiSoundPlayer.get_node('playerMenuOpen').play()
			else:
				$gameLayer/HUDLayer/playerMenu/AnimationPlayer.play('slide_up')
				player_menu_on_screen = true
				UiSoundPlayer.get_node('playerMenuClose').play()

# for movement shit
func _physics_process(delta):
	if $gameLayer.visible and not in_combat:
		var partyLeader = $gameLayer/partyMembers/CharacterBody2D
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		partyLeader.velocity = input_dir.normalized() * 50
		partyLeader.move_and_collide(partyLeader.velocity * delta)
		
		# make any other party members follow:
		if $gameLayer/partyMembers.get_children().size() > 1:
			var i = 1
			for otherpartymember in $gameLayer/partyMembers.get_children().slice(1):
				otherpartymember.velocity = ($gameLayer/partyMembers.get_children()[i-1].position - otherpartymember.position - input_dir*10).normalized() * 50
				otherpartymember.move_and_collide(otherpartymember.velocity * delta)
				i += 1
				if i == 4:
					i = 1
func showLoadingLayer(text, next_layer):
	hideAllLayers()
	$loadingLayer/Panel/RichTextLabel.clear()
	$loadingLayer/Panel/RichTextLabel.append_text(text)
	$loadingLayer/Panel/RichTextLabel.visible_ratio = 0
	$loadingLayer.show()
	next_layer_after_loading = next_layer
	var tween = get_tree().create_tween()
	self.tweens.append(tween)
	tween.tween_property($loadingLayer/Panel/RichTextLabel, "visible_ratio", 1, 10)
	
# start a new game
func _on_button_pressed():
	showLoadingLayer(lorem, $gameLayer)
	
	# create a new game with default player data
	GlobalVars.load_default_player_data()
	self.player_data = GlobalVars.player_data
	party.append(player_data)
	 
	# add a stats tab for the player's character
	var scene2 = preload("res://scenes/memberStats.tscn")
	var instance2 = scene2.instantiate()
	instance2.set_char_data(player_data)
	$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer/Stats/TabContainer.add_child(instance2)
	
	# TODO: RESET THE MAP AND WORLD STATE
	
	# Add some players to the party
	addPartyMember()
	
	# update the player's menus
	updateStatsTab()
	updateBagTab()
	
	# TODO: automatically hop into combat
	startCombat() # for testing purposes

func hideAllLayers():
	#$gameLayer/HUDLayer/playerMenu/AnimationPlayer.play('slide_down')
	#player_menu_on_screen = false
	for child in get_children():
		if (child is CanvasLayer and child != $CRT) or child == $gameLayer:
			child.hide()
	
func _on_tab_container_tab_hovered(_tab):
	UiSoundPlayer.get_node('buttonSoundHover').play()

func _on_tab_container_tab_clicked(_tab):
	UiSoundPlayer.get_node('buttonSound').play()

func _on_button_pressed_exit_menu():
	# turn off combat if you exited to menu while in combat
	_set_in_combat(false)
	# hide the player menu
	$gameLayer/HUDLayer/playerMenu/AnimationPlayer.play('slide_down')
	player_menu_on_screen = false
	hideAllLayers()
	$menuLayer.show()
	
func _on_button_3_pressed():
	var text = "I'd like to thank absolutely fucking no one. Jk. I'd like to thank my girlfriend Mar."
	self.showLoadingLayer(text, $menuLayer)

func _on_button_3_pressed_save_game():
	if not in_combat:
		GlobalVars.save_player_data()
		$gameLayer/HUDLayer/Panel/saveIcon.show()
		UiSoundPlayer.get_node('saveSound').play()
		await get_tree().create_timer(2).timeout
		$gameLayer/HUDLayer/Panel/saveIcon.hide()
	
func hide_enemy_combat_chat_message():
	$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/enemyParty/enemyChatPanel.hide()
		
func show_enemy_combat_chat_message(message_text: String, message_texture: CompressedTexture2D):
	$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/enemyParty/enemyChatPanel/HBoxContainer/charSpeakingRichText.clear()
	$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/enemyParty/enemyChatPanel/HBoxContainer/charSpeakingRichText.append_text('\n' + message_text + '\n')
	$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/enemyParty/enemyChatPanel/HBoxContainer/charSpeakingTexture.texture = message_texture
	$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/enemyParty/enemyChatPanel.show()

func _on_submit_move_pressed():
	if engine.playerTurn:
		engine.nextTurn()

func updateStatsTab():
	# cycle through tab nodes and update them
	for tab in $gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer/Stats/TabContainer.get_children():
		tab.updateMemberStats()
	
func updateBagTab():
	for child in $gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer/Bag/HSplitContainer/ScrollContainer/VBoxContainer.get_children():
		child.queue_free()
		
	for item_id in player_data.bag:
		var scene = preload("res://scenes/templateItemButton.tscn")
		var instance = scene.instantiate()
		instance.set_item_id(item_id)
		$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer/Bag/HSplitContainer/ScrollContainer/VBoxContainer.add_child(instance)

func discard_item(item_id):
	if item_id in player_data.bag:
		player_data.bag.erase(item_id)
	updateBagTab()

# TODO: MAKE THIS WORK FOR EACH PARTY MEMBER
func equip_item(item_id):
	if item_id in player_data.bag:
		player_data.bag.erase(item_id)
	updateBagTab()
	
# TODO: MAKE THIS WORK FOR EACH PARTY MEMBER
func consume_item(partyMember_index, item_id, currents_adjust = null):
	var partyMemberData = party[partyMember_index]
	if not currents_adjust:
		currents_adjust = GlobalVars.returnDocInList(GlobalVars.lore_data.items, 'item_id', item_id)
	if item_id in player_data.bag:
		player_data.bag.erase(item_id)
		# apply item effects
		partyMemberData.old_currents = partyMemberData.currents.duplicate(true)
		partyMemberData.currents = GlobalVars.addJSONObjs(partyMemberData.currents, currents_adjust)
	updateBagTab()
	updateStatsTab()
	
	if in_combat:
		engine.playerPartyNode.get_children()[partyMember_index].animate_to_new_currents()
		engine.nextTurn()

# TODO: actually accept some arguments eventually
func addPartyMember():
	var scene = preload("res://scenes/partyMember.tscn")
	var instance = scene.instantiate()
	# TODO: make an actual constructor function
	$gameLayer/partyMembers.add_child(instance)
	self.party.append(instance.char_data)
	
	# add a stats tab to the player menu for the party member
	var scene2 = preload("res://scenes/memberStats.tscn")
	var instance2 = scene2.instantiate()
	instance2.set_char_data(instance.char_data)
	$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer/Stats/TabContainer.add_child(instance2)

func _on_v_slider_value_changed(value):
	var sfx_index = AudioServer.get_bus_index("music")
	AudioServer.set_bus_volume_db(sfx_index, value)

func _on_v_slider2_value_changed(value):
	var sfx_index = AudioServer.get_bus_index("sounds")
	AudioServer.set_bus_volume_db(sfx_index, value)
