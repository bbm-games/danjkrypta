extends Node

var player_data
var lore_data

var scene_to_change_to
var is_loading = false

var rng = RandomNumberGenerator.new()

func get_randomized_char_data(): 
	var randomized_char_data = {
		'char_name': self.generate_word(7),
		'char_texture': 'res://assets/DoomcryptKit/Single-Characters/' + self.choose_random_from_list(self.dir_contents("res://assets/DoomcryptKit/Single-Characters/")),
		'stats':{
			'max_hp': rng.randi_range(0, 200), 
			'max_mp': rng.randi_range(0, 200),
			'initiative': rng.randi_range(0, 10), # who goes first during turn based combat
			
			# How well you can resist damage to MP and HP
			'magic_resist': rng.randf_range(0, 25), # how well you can withstand magic attacks
			'physical_resist': rng.randf_range(0, 25), # how well you can withstand physical attacks
			
			# Status effect resistances (base determined by class)
			'plagued_resist': rng.randf_range(0, 25), # how well you can withstand plague attacks
			'burned_resist': rng.randf_range(0, 25),
			'poisoned_resist': rng.randf_range(0, 25)
		},
		'currents':{
			'hp': null,
			'mp': null,
			'plagued': rng.randf_range(0, .5), # for instant death mechanic
			'burned': rng.randf_range(0, .5), # for damage over time mechanic
			'poisoned': rng.randf_range(0, .5) # for skipping moves mechanic
		},
		'exp': 0.0,
		'gold': rng.randi_range(0, 1000),
		'is_dead': false,
		'is_paralyzed': false,
		'moves': [{
			'move_id': 'move001',
			'move_name': 'basic_attack',
			'move_desc': 'A simple punch',
			'damage_obj': {
				'hp':10,
				'mp':0,
				'plagued': 0,
				'poisoned': 0,
				'burned': 0
			},
		}],
		'bag': [
			{
				'item_id': 'item001',
				'item_name': 'Healing Potion',
				'item_desc': 'Heals your health.',
				'consumable': {
					'currents_adjust':{
						'hp': 25,
						'mp': 0,
						'plagued': 0,
						'burned': 0,
						'poisoned': 0
					}
				}
			},
			{
				'item_id': 'item002',
				'item_name': 'Mana Potion',
				'item_desc': 'Restores your mana.',
				'consumable': {
					'currents_adjust':{
						'hp': 0,
						'mp': 25,
						'plagued': 0,
						'burned': 0,
						'poisoned': 0
					}
				}
			}
			
		],
		'equipment':{
			'head': {
				'item_id': 'item003',
				'item_name': 'Trash Helmet',
				'item_desc': 'A helmet worn by low level mobs.',
				'equippable': {
					'stats_adjust':{
						'max_hp': 50, 
						'max_mp': 0,
						'initiative': 0,
						
						'magic_resist': 1,
						'physical_resist': 1,
						
						'plagued_resist': 5,
						'burned_resist': 5,
						'poisoned_resist': 5
					}
				}
			},
			'body': null,
			'legs': null,
			'weapon': null,
			'talisman': null,
		}
	}
	return randomized_char_data

func _ready():
	#get lore data
	var file = FileAccess.open("res://lore/danjlore.json", FileAccess.READ)
	lore_data = JSON.parse_string(file.get_as_text())
	file.close()
	load_default_player_data()
	
	# check if save directory exists or make one
	var dir = DirAccess.open("user://")
	if not dir.dir_exists('saves'):
		dir.make_dir('saves')

func load_default_player_data():
	# get player data (default one in lore file)
	"var file = FileAccess.open('res://lore/danjlore.json', FileAccess.READ)
	player_data = JSON.parse_string(file.get_as_text())['character']
	file.close()"
	player_data = GlobalVars.get_randomized_char_data()

func load_player_data(path):
	var file = FileAccess.open(path, FileAccess.READ)
	player_data = JSON.parse_string(file.get_as_text())
	file.close()

func save_player_data():
	var file = FileAccess.open("user://saves/" + GlobalVars.player_data['name'] + '.json', FileAccess.WRITE)
	file.store_string(JSON.stringify(GlobalVars.player_data))
	file.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# useful function for searching through a list of json documents 
# and retrieving the value for a key for a document that has a certain id
func searchDocsInList(list, uniquekey: String, uniqueid: String, key: String):
	for doc in list:
		if doc[uniquekey] == uniqueid:
			if key in doc.keys():
				return doc[key]
			else:
				return null
	return null

# useful function for searching through a list of json documents
# and retrieving doc where there is a certain value for a certain key
func returnDocInList(list, uniquekey, uniqueid):
	for doc in list:
		if doc[uniquekey] == uniqueid:
			return doc
	return null
	
# useful function for making an array unique
func array_unique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

#useful function for picking a random value from a list
func choose_random_from_list(rand_list):
	return rand_list[randi() % rand_list.size()]

#useful function for returning a list of files in a directory
func dir_contents(path):
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				#print("Found directory: " + file_name)
				pass
			else:
				if file_name.find('.import') == -1:
					#print("Found file: " + file_name)
					files.append(file_name)
			file_name = dir.get_next()
	else:
		#print("An error occurred when trying to access the path.")
		pass
	return files


func generate_word(length):
	var chars = 'abcdefghijklmnopqrstuvwxyz'
	var word: String = ''
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word
