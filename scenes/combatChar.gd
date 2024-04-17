extends VBoxContainer


func _on_char_image_mouse_entered():
	$focused.show()
	UiSoundPlayer.get_node('buttonSoundHover').play()

func _on_char_image_mouse_exited():
	$focused.hide()
	
func take_damage():
	$hurtSound.play()
	$charImage/AnimationPlayer.play('hurt')

func _on_char_image_gui_input(event):
	if event is InputEventMouseButton:
			if event.pressed:
				take_damage()
