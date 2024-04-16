extends Node

func _ready():
	# when _ready is called, there might already be nodes in the tree, so connect all existing buttons
	connect_buttons(get_tree().root)
	get_tree().connect("node_added", _on_SceneTree_node_added)

func _on_SceneTree_node_added(node):
	if node is Button:
		connect_to_button(node)

func _on_Button_pressed():
	$buttonSound.play()
	
func _on_Button_hovered():
	$buttonSoundHover.play()

# recursively connect all buttons
func connect_buttons(root):
	for child in root.get_children():
		if child is BaseButton:
			connect_to_button(child)
		connect_buttons(child)

func connect_to_button(button):
	button.connect("pressed", _on_Button_pressed)
	button.connect("mouse_entered", _on_Button_hovered)
