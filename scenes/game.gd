extends Node2D

var lorem = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
var player_data = {'posX': 0, 'posY': 0}
var tweens = []
var player_menu_on_screen = false
var text_done_showing_counter = 0

var in_combat = true
var next_layer_after_loading = null

func _ready():
	# hide all shit
	hideAllLayers()
	
	# Start title screen music
	$backgroundMusicPlayer.play()
	$menuLayer.show()

func _on_button_4_pressed():
	get_tree().quit()
	
func _process(delta):
	if $gameLayer.visible:
		$gameLayer/CharacterBody2D.position = $gameLayer/CharacterBody2D.position.lerp(Vector2(player_data.posX, player_data.posY) * 16, delta*10)
		if in_combat:
			$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay.show()
		else:
			$gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect/combatDisplay.hide()
	if $loadingLayer.visible:
		if $loadingLayer/Panel/RichTextLabel.visible_ratio >= 1:
			text_done_showing_counter += delta
	else:
		text_done_showing_counter = 0
		
func _input(event):
	if $loadingLayer.visible:
		if Input.is_anything_pressed() and $loadingLayer/Panel/RichTextLabel.visible_ratio < 1:
			for tween in tweens:
				tween.stop()
			$loadingLayer/Panel/RichTextLabel.visible_ratio = 1
		if Input.is_anything_pressed() and $loadingLayer/Panel/RichTextLabel.visible_ratio == 1 and text_done_showing_counter > 0.25:
			hideAllLayers()
			text_done_showing_counter = 0
			next_layer_after_loading.show()
		
	if $gameLayer.visible:
		if event.is_action_pressed("move_up"):
			player_data.posY -= 1
		elif event.is_action_pressed("move_down"):
			player_data.posY += 1
		elif event.is_action_pressed("move_left"):
			player_data.posX -= 1
		elif event.is_action_pressed("move_right"):
			player_data.posX += 1
			
		if event.is_action_pressed('menu'):
			if player_menu_on_screen:
				$gameLayer/HUDLayer/playerMenu/AnimationPlayer.play('slide_down')
				player_menu_on_screen = false
				UiSoundPlayer.get_node('playerMenuOpen').play()
			else:
				$gameLayer/HUDLayer/playerMenu/AnimationPlayer.play('slide_up')
				player_menu_on_screen = true
				UiSoundPlayer.get_node('playerMenuClose').play()
		
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
	
func _on_button_pressed():
	showLoadingLayer(lorem, $gameLayer)
	# create a new game
	self.player_data = {'posX': 0, 'posY': 0}

func hideAllLayers():
	for child in get_children():
		if child is CanvasLayer and child != $CRT:
			child.hide()
	$gameLayer/HUDLayer/playerMenu/AnimationPlayer.play('slide_down')
	player_menu_on_screen = false
	
func _on_tab_container_tab_hovered(tab):
	UiSoundPlayer.get_node('buttonSoundHover').play()

func _on_tab_container_tab_clicked(tab):
	UiSoundPlayer.get_node('buttonSound').play()

func _on_button_pressed_exit_menu():
	hideAllLayers()
	$menuLayer.show()


func _on_button_3_pressed():
	var text = "I'd like to thank absolutely fucking no one. Jk. I'd like to thank my girlfriend Mar."
	self.showLoadingLayer(text, $menuLayer)
