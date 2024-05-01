extends CharacterBody2D

var char_data

func _init():
	# FOR NOW JUST SET THE MEMBER'S DATA TO SOME RANDOM SHIT
	self.char_data = GlobalVars.get_randomized_char_data()

func _ready():
	pass
