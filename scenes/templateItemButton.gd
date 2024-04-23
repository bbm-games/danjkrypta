extends Button

var item_data: Variant
var main_game_node: Node
var descriptionRichText: Node

func set_item_id(item_id = 'item001'):
	self.item_data = GlobalVars.returnDocInList(GlobalVars.lore_data.items, 'item_id', item_id).duplicate(true)

func _ready():
	self.set_item_id()
	main_game_node = get_tree().get_root().get_node('Node2D')
	descriptionRichText = main_game_node.get_node('gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer/Bag/HSplitContainer/RichTextLabel')
	self.text = self.item_data.item_name
	if 'item_texture' in self.item_data:
		self.icon = load(self.item_data.item_texture)

func _on_pressed():
	descriptionRichText.clear()
	descriptionRichText.append_text(item_data.item_desc + '\n')
	if 'consumable' in item_data:
		descriptionRichText.append_text('HP: ' + GlobalVars.num2signedstr(item_data.consumable.currents_adjust.hp) + '\n')
		descriptionRichText.append_text('MP: ' + GlobalVars.num2signedstr(item_data.consumable.currents_adjust.mp) + '\n')
		descriptionRichText.append_text('Plagued: ' + GlobalVars.num2signedstr(item_data.consumable.currents_adjust.plagued) + '\n')
		descriptionRichText.append_text('Burned: ' + GlobalVars.num2signedstr(item_data.consumable.currents_adjust.burned) + '\n')
		descriptionRichText.append_text('Poisoned: ' + GlobalVars.num2signedstr(item_data.consumable.currents_adjust.poisoned) + '\n')
	
	# update the action buttons
	main_game_node.get_node('gameLayer/HUDLayer/playerMenu/VBoxContainer/ColorRect2/TabContainer/Bag/HSplitContainer/itemActionOptions').updateOptionButtons(item_data)
