extends Node2D

var lorem = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
var player_data = {'posX': 0, 'posY': 0}
var tweens = []
var player_menu_on_screen = false
var text_done_showing_counter = 0

var walk_up_held = false
var walk_down_held = false
var walk_left_held = false
var walk_right_held = false

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
	
	# Start title screen music
	$backgroundMusicPlayer.play()
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
	
func combat_log_append(text_given: String):
	$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/playerParty/combatLog.newline()
	$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay/VBoxContainer2/playerParty/combatLog.append_text(text_given)

func _on_button_4_pressed():
	get_tree().quit()
	
func _process(delta):
	if $gameLayer.visible:
		#$gameLayer/CharacterBody2D.position = $gameLayer/CharacterBody2D.position.lerp(Vector2(player_data.posX, player_data.posY) * 16, delta*10)
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
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		$gameLayer/CharacterBody2D.velocity = input_dir.normalized() * 50
		$gameLayer/CharacterBody2D.move_and_collide($gameLayer/CharacterBody2D.velocity * delta)
	
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
	
	# create a new game with default player date
	GlobalVars.load_default_player_data()
	self.player_data = GlobalVars.player_data
	
	# TODO: RESET THE MAP AND WORLD STATE
	
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
