extends VBoxContainer

func updateOptionButtons(item_data):
	$Consume.hide()
	$Equip.hide()
	if 'consumable' in item_data:
		$Consume.show()
	if 'equippable' in item_data:
		$Equip.show()
	$Discard.show()
