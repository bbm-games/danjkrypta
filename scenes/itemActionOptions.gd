extends VBoxContainer
var current_item_data:Variant
var main_game_node

func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')

func _process(_delta):
	if current_item_data:
		if main_game_node.in_combat:
			if not main_game_node.engine.playerTurn:
				$Consume.disabled = true
				$Equip.disabled = true
			else:
				$Consume.disabled = false
				$Equip.disabled = false
				
func updateOptionButtons(item_data):
	current_item_data = item_data
	$Consume.hide()
	$Equip.hide()
	if 'consumable' in item_data:
		$Consume.show()
	if 'equippable' in item_data:
		$Equip.show()
	$Discard.show()
	
	# make the consume button drop-down menu populated by party members
	$Consume.get_popup().clear()
	
	for partyMember in main_game_node.party:
		$Consume.get_popup().add_item(partyMember.char_name)

	$Consume.get_popup().id_pressed.connect(_on_consume_id_pressed)

func _on_discard_pressed():
	$Consume.hide()
	$Equip.hide()
	$Discard.hide()
	main_game_node.discard_item(current_item_data.item_id)
	main_game_node.get_node('gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer/Bag/HSplitContainer/RichTextLabel').clear()

func _on_consume_id_pressed(id: int):
	$Consume.hide()
	$Equip.hide()
	$Discard.hide()
	main_game_node.consume_item(id, current_item_data.item_id, current_item_data.consumable.currents_adjust)
	main_game_node.get_node('gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer/Bag/HSplitContainer/RichTextLabel').clear()
