extends TabBar
var player_data

func _init():
	pass
	
func set_char_data(char_data_given):
	self.player_data = char_data_given
	self.set_name(player_data.char_name)
	
func updateMemberStats():
	$HBoxContainer/VBoxContainer/Label.text = player_data.char_name
	$HBoxContainer/VBoxContainer/TextureRect.texture = load(player_data.char_texture)
	var statRichText = $HBoxContainer/RichTextLabel
	var statRichText2 = $HBoxContainer/RichTextLabel2
	statRichText.clear()
	statRichText2.clear()
	statRichText.append_text('HP: ' + str(player_data.currents.hp) + '/' + str(player_data.stats.max_hp) + '\n')
	statRichText.append_text('MP: ' + str(player_data.currents.mp) + '/' + str(player_data.stats.max_mp) + '\n')
	statRichText.append_text('Init: '+ str(player_data.stats.initiative) + '\n')
	statRichText.append_text('Gold: '+ str(player_data.gold) + '\n')
	statRichText.append_text('Exp: '+ str(player_data.exp) + '\n')
	
	statRichText2.append_text('Magic Resist: ' + str(int(player_data.stats.magic_resist)) + '\n')
	statRichText2.append_text('Physical Resist: ' + str(int(player_data.stats.physical_resist)) + '\n')
	statRichText2.append_text('Plagued Resist: ' + str(int(player_data.stats.plagued_resist)) + '\n')
	statRichText2.append_text('Burned Resist: ' + str(int(player_data.stats.burned_resist)) + '\n')
	statRichText2.append_text('Poisoned Resist: ' + str(int(player_data.stats.poisoned_resist)) + '\n')

func _ready():
	updateMemberStats()
