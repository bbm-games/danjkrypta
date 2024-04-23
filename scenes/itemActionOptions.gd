extends VBoxContainer
var current_item_data:Variant
var main_game_node

func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')

func updateOptionButtons(item_data):
	current_item_data = item_data
	$Consume.hide()
	$Equip.hide()
	if 'consumable' in item_data:
		$Consume.show()
	if 'equippable' in item_data:
		$Equip.show()
	$Discard.show()

func _on_discard_pressed():
	$Consume.hide()
	$Equip.hide()
	$Discard.hide()
	main_game_node.discard_item(current_item_data.item_id)
	main_game_node.get_node('gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer/Bag/HSplitContainer/RichTextLabel').clear()
