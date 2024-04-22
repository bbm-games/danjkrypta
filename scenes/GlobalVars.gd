extends Node

var player_data
var lore_data

var scene_to_change_to
var is_loading = false

var rng = RandomNumberGenerator.new()

var char_pic_names = ["VampireNoble4.png", "AmazonChampion3.png", "Crocbear2.png", "Werewolf3.png", "Oxbear1.png", "Werewolf2.png", "Crocbear3.png", "DrakeHero4.png", "AmazonChampion2.png", "DarkElfSentry4.png", "Crocbear1.png", "Oxbear3.png", "Oxbear2.png", "Werewolf1.png", "AmazonChampion1.png", "DrakeHero3.png", "VampireNoble2.png", "DarkElfSentry1.png", "Crocbear4.png", "Werewolf4.png", "VampireNoble3.png", "AmazonChampion4.png", "DrakeHero2.png", "VampireNoble1.png", "DarkElfSentry2.png", "Oxbear4.png", "DarkElfSentry3.png", "DrakeHero1.png", "HalfHumanRanger3.png", "ElfWarden2.png", "DarkElfOverseer3.png", "HumanRogue3.png", "SkeletonLich1.png", "DarkElfInvader4.png", "SkeletonSword1.png", "HumanRogue2.png", "DarkElfOverseer2.png", "ElfWarden3.png", "HalfHumanRanger2.png", "OrcRaider4.png", "DrakeAdult4.png", "ElfWarden1.png", "SkeletonSword3.png", "SkeletonLich3.png", "HumanWarrior4.png", "SkeletonLich2.png", "SkeletonSword2.png", "HumanRogue1.png", "DarkElfOverseer1.png", "HalfHumanRanger1.png", "OrcRaider3.png", "DrakeAdult1.png", "ElfWarden4.png", "DarkElfInvader3.png", "HumanWarrior1.png", "DarkElfInvader2.png", "DarkElfOverseer4.png", "HumanRogue4.png", "HalfHumanRanger4.png", "OrcRaider2.png", "DrakeAdult2.png", "HumanWarrior2.png", "SkeletonLich4.png", "HumanWarrior3.png", "DarkElfInvader1.png", "SkeletonSword4.png", "DrakeAdult3.png", "OrcRaider1.png", "SkeletonSpear4.png", "HumanBarbarian2.png", "AmazonGuardian3.png", "Skeleton4.png", "Vampire1.png", "AmazonWarrior4.png", "SkeletonKnight4.png", "HumanBarbarian3.png", "AmazonGuardian2.png", "HumanPaladin1.png", "DrakeYouth4.png", "HumanPaladin3.png", "HumanBarbarian1.png", "Vampire2.png", "DrakeElder4.png", "HumanWarlock4.png", "ElfArcher4.png", "Vampire3.png", "Owlbear4.png", "AmazonGuardian1.png", "HumanPaladin2.png", "SkeletonSpear2.png", "DrakeYouth3.png", "HumanBarbarian4.png", "Skeleton2.png", "SkeletonKnight3.png", "AmazonWarrior2.png", "AmazonWarrior3.png", "DrakeElder1.png", "HumanWarlock1.png", "SkeletonKnight2.png", "ElfArcher1.png", "Skeleton3.png", "Owlbear1.png", "AmazonGuardian4.png", "DrakeYouth2.png", "SkeletonSpear3.png", "SkeletonSpear1.png", "Skeleton1.png", "Owlbear3.png", "ElfArcher3.png", "Vampire4.png", "HumanWarlock3.png", "AmazonWarrior1.png", "DrakeElder3.png", "DrakeElder2.png", "SkeletonKnight1.png", "HumanWarlock2.png", "ElfArcher2.png", "Owlbear2.png", "DrakeYouth1.png", "HumanPaladin4.png", "HumanPriest1.png", "AmazonWitch4.png", "WerewolfAlpha4.png", "OrcChopper1.png", "OrcBrute3.png", "OrcBrute2.png", "OrcGrunt1.png", "Ghoul1.png", "Ghoul3.png", "HumanPriest2.png", "OrcGrunt3.png", "OrcChopper2.png", "ElfKeeper4.png", "OrcBrute1.png", "HumanThief4.png", "Goblin4.png", "OrcChopper3.png", "OrcGrunt2.png", "ElfLord4.png", "DarkElfMarauder4.png", "HumanPriest3.png", "Ghoul2.png", "AmazonWitch2.png", "WerewolfAlpha2.png", "OrcBrute4.png", "ElfKeeper1.png", "Goblin1.png", "HumanThief1.png", "ElfLord1.png", "DarkElfMarauder1.png", "WerewolfAlpha3.png", "AmazonWitch3.png", "HumanPriest4.png", "AmazonWitch1.png", "WerewolfAlpha1.png", "DarkElfMarauder3.png", "ElfLord3.png", "HumanThief3.png", "Goblin3.png", "OrcChopper4.png", "ElfKeeper3.png", "ElfKeeper2.png", "Goblin2.png", "HumanThief2.png", "ElfLord2.png", "OrcGrunt4.png", "DarkElfMarauder2.png", "Ghoul4.png"]

func get_randomized_char_data(): 

	var randomized_char_data = {
		'char_name': self.generate_word(7),
		#'char_texture': 'res://assets/DoomsphereCharset/Single PNGs/Outline/' + self.choose_random_from_list(self.dir_contents("res://assets/DoomsphereCharset/Single PNGs/Outline/")),
		'char_texture': 'res://assets/DoomsphereCharset/Single PNGs/Outline/' + self.choose_random_from_list(char_pic_names),
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
				if file_name.find('.import') == -1 and file_name.find('.png') != -1:
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
