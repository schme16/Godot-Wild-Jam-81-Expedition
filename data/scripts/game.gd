extends Node2D

enum states {
	main_menu,
	new_game,
	picking_loadout,
	sailing,
	in_dialogue,
	in_event,
	pause_menu,
	highscores,
	game_over,
	win,
	options,
}

enum difficulties {
	easy,
	normal,
	hard
}
@export var difficulty:difficulties

@export var number_of_encounters_for_difficulty:Dictionary = {
	difficulties.easy:3,
	difficulties.normal:3,
	difficulties.hard:3,
}

@export var player_speeds_for_difficulty:Dictionary = {
	difficulties.easy:250,
	#difficulties.easy:500,
	difficulties.normal:350,
	difficulties.hard:500,
}

@export var journey_times_for_difficulty:Dictionary = {
	difficulties.easy:60,
	difficulties.normal:180,
	difficulties.hard:360,
}

var shoreline = preload("res://data/prefabs/encounter_shoreline.tscn")

@export var player:Node2D
@onready var clouds_1: Node2D = $"Clouds 1"
@onready var clouds_2: Node2D = $"Clouds 2"

@export var camera:Camera2D
@export var number_of_encounters:float = 0
@export var start_progress:float = 0
@export var selected_journey_time:float = 180
var journey_time:float
@export var progress:float
@export var editor_only_items:Node2D




@export var player_speed_menu:float = 60
@export var selected_player_speed:float = 250
@export var _player_speed:float = 250
var player_speed:float

@export var _ship_health:float = 100
var ship_health:float

@export var _ship_morale:float = 100
var ship_morale:float

@export var state:states
var last_state:states = -1

@onready var ui: Control = $"CanvasLayer/in-game ui"
var gradient_red_orange_green = Gradient.new()

@export var max_roll:int = 7
@export var picked_items:Array

var last_check_zone:float
var last_check_failed:int
var current_journey_time:float



@onready var objects_list: Dictionary = {
	"rock": preload("res://data/prefabs/rock.tscn"),
	"shark": preload("res://data/prefabs/shark_fin.tscn"),
	"sunken_ship": preload("res://data/prefabs/sunken_ship.tscn"),
}
var objects_list_array:Array

@onready var objects: Node2D = $"objects"




#sfx
var sfx_ui_click = preload("res://data/sfx/ButtonSound.mp3")




#ui stuff
@onready var ui_easy_button: Button = $CanvasLayer/main_menu/Panel/VBoxContainer2/VBoxContainer/Easy
@onready var ui_first_loadout_button: Button = $"CanvasLayer/picking_loadout/Panel/MarginContainer/VBoxContainer/HBoxContainer/items list/bucket_of_fish"
@onready var ui_begin_button: Button = $"CanvasLayer/picking_loadout/Panel/MarginContainer/VBoxContainer/MarginContainer/Begin button"
@onready var ui_retry_button: Button = $CanvasLayer/game_over/Panel/VBoxContainer2/VBoxContainer/Retry
@onready var ui_unpause_button: Button = $"CanvasLayer/pause_menu/Panel/VBoxContainer2/Unpause button"
@onready var ui_play_again: Button = $"CanvasLayer/win/Panel/VBoxContainer2/VBoxContainer/Play again"
@onready var ui_win_text: RichTextLabel = $"CanvasLayer/win/Panel/VBoxContainer2/Win text"
@onready var ui_sfx_volume: HSlider = $CanvasLayer/options/Panel/MarginContainer/VBoxContainer/sfx_volume
@onready var ui_music_volume: HSlider = $CanvasLayer/options/Panel/MarginContainer/VBoxContainer/music_volume


@onready var ui_voyage_tracker: Control = $"CanvasLayer/in-game ui/voyage_tracker"
@onready var ui_voyage_tracker_current: ColorRect = $"CanvasLayer/in-game ui/voyage_tracker/current"

@onready var ui_ship_health: Control = $"CanvasLayer/in-game ui/ship_health"
@onready var ui_ship_health_current: ColorRect = $"CanvasLayer/in-game ui/ship_health/current"


@onready var ui_crew_morale: Control = $"CanvasLayer/in-game ui/crew_morale"
@onready var ui_happy: Sprite2D = $"CanvasLayer/in-game ui/crew_morale/happy"
@onready var ui_ok: Sprite2D = $"CanvasLayer/in-game ui/crew_morale/ok"
@onready var ui_sad: Sprite2D = $"CanvasLayer/in-game ui/crew_morale/sad"

@onready var background_music: AudioStreamPlayer2D = $Camera/background_music

@onready var seagull: Sprite2D = $Player/sprite/seagull
var player_sprite_0 = preload("res://data/textures/Boat0.png")
var player_sprite_1 = preload("res://data/textures/Boat1.png")

#dialogue stuff
var current_dialogue:Dictionary
var current_dialogue_section:String
var current_dialogue_index:int
@onready var ui_dialogue_text: RichTextLabel = $"CanvasLayer/dialogue/Panel/dialogue box/dialogue text"
@onready var ui_next_dialogue: Button = $"CanvasLayer/dialogue/Panel/dialogue box/Control/Next dialogue"
@onready var ui_dialogue_box: VBoxContainer = $"CanvasLayer/dialogue/Panel/dialogue box"
@onready var ui_dialogue_item_picker: HBoxContainer = $"CanvasLayer/dialogue/Panel/dialogue item picker"
@onready var ui_first_pickable_dialogue_item: Button = $"CanvasLayer/dialogue/Panel/dialogue item picker/item"
@onready var ui_second_pickable_dialogue_item: Button = $"CanvasLayer/dialogue/Panel/dialogue item picker/item2"
@onready var ui_third_pickable_dialogue_item: Button = $"CanvasLayer/dialogue/Panel/dialogue item picker/item3"
@export var picked_dialogue_item:Button

var dialogue:Dictionary = {


	"seal_a": {
		"required_item": "bucket_of_fish",

		"intro": [
			"A huge seal leaps onto the boat and makes a beeline for one of the crew members. \nThe crew member terrified, attempts to get out of the way, to no avail. \nThe sea doggo rubs up against him, unfortunately beginning to crush him.",
			"\n[font_size=40]\n[/font_size][center]Quick, pick an item![/center]",


		],

		"success": [
			"You toss over the [color=green]<picked_item_name>[/color] over the side and the seal leaps after the free snack. \nThe crew member shakily gets to his feet, relieved.",
			"Now let's get out of here!",
		],

		"failure": [
			"You attempt to use the [color=red]<picked_item_name>[/color] on the seal. \nThe seal seems unbothered by your actions and continues roll on the crew member. \nIt eventually loses interest and galomphs away and off the boat, but not before the breaking the poor man's legs. He is not happy."
		],
	},

	"seal_b": {
		"required_item": "juicy_fish",

		"intro": [
			"A giant seal is blocking your path",
			"The crew are shouting, trying to shoo it away, but it hasn't even noticed them....",
			"\n[font_size=40]\n[/font_size][center]Maybe you have something that can get it's attendtion?[/center]",


		],

		"success": [
			"You wave around the [color=green]<picked_item_name>[/color].",
			"You've definitly got it's attention!. \nYou throw the fish overboard as far from the path as possible, and watch as it quickly swims after it.",
			"Time to go!",
		],

		"failure": [
			"You attempt to get it's attention with the [color=red]<picked_item_name>[/color]",
			"It doesn't really seem to care... \nBut you've got a job to do, so order the sails raised, and ram the beast aside.",
			"The crew are not happy that you'd hurt such an innocent animal..."
		],
	},

	"seal_c": {
		"required_item": "beach_ball",

		"intro": [
			"A flock of seals are playing in the water \nThe crew are watching, facinated, and won't return to their posts.",
			"[center]Perhaps there's something you can give them to encourage them to take their fun elsewhere?[/center]",


		],

		"success": [
			"You throw the [color=green]<picked_item_name>[/color].",
			"The seals love it!\nOne begins to balance it on it's nose, and the others quickly start chasing them around, eventually swiming off after them. \n \nThe crew cheer and clap as they go!",
			"\"Alright, back to work you lot!\" \n\nTime to set off again.",
		],

		"failure": [
			"You dump the [color=red]<picked_item_name>[/color] into the water",
			"It scares the seals who immediatly dip below the water's surface.",
			"The crew glare at you, upset you ruined their fun."
		],
	},



	"seagull_a": {
		"required_item": "box_of_chips",

		"intro": [
			"It has been smooth sailing thus far, but now you face one of the most dangerous situations you've ever encountered.",
			"A seagull nesting ground lies ahead, and all attempts to pass has been mith the vicious nips and pecks, and what they've done to the poop deck has give it entirely new meaning! (it may never be clean again...)",
			"[center]Think! Surely you have something onboard that can help?[/center]",


		],

		"success": [
			"You throw the [color=green]<picked_item_name>[/color].",
			"The seagulls stop still for a second, before erupting in a raucous cacophony, and darting as one towards where it landed and breaking out into a fight that I'm sure their grandchildred will hear squawk of!",
			"You leave hastily while the brawl continues.",
		],

		"failure": [
			"You attept to throw the [color=red]<picked_item_name>[/color] towards the swarm, but it lands onto one of the crew's helmets.",
			"The gulls now focus on the poor soul, and launch another attack. \nYou decide to hell with it and raise the main sails to full, fleeing the scene, but not before your crew member loses an eye to those monsters.",
			"You continue your journey, but the atmosphere on the ship has soured considerably..."
		],
	},

	"seagull_b": {
		"required_item": "sandwich",

		"intro": [
			"You approach a rock covered in seagulls, as you get close they start taking off and circling overhead, covering the ship in their mess (if only you packed an umbrella!)",
			"[center]How can you get rid of them?![/center]",
		],

		"success": [
			"While you were thinking, a crew member pulls out their [color=green]<picked_item_name>[/color]. Emergency be damned, it was his union mandated lunch break!",
			"Before they can even take the first bite the gulls swoop, stealing it from his hands and darting back to their rocky home.",
			"Before you can even give the order to continue, let alone console the man about his lost meal, he slides a second one from under his coat, and smiles.",
		],

		"failure": [
			"You try and shoo them with [color=red]<picked_item_name>[/color], but it does little to disperse the flock.",
			"Eventually the gulls decide you've got nothing worth taking and leave, and now you and the crew will need to clean the ship in its entirety.",
			"A collective groan is let out as you give the order. It will be a looong day..."
		],
	},

	"seagull_c": {
		"required_item": "packet_of_chips",
		"set_flag_on_success":"seagull_mascot",
		"intro": [
			"You happen upon a rock, whose sole occupant is a large seagull",
			"It flys over to the ship, and begins beaking around, looking for something, in doing so it is casuing chaos among the crew with several crew members try to catch the bird, but it flaps just out of reach each time.",
			"Maybe if you offer it the right thing you can get the bird to leave?",
		],

		"success": [
			"You head to the stores and retrieve the [color=green]<picked_item_name>[/color] you had stored down there",
			"Far from convicning the bird to leave, he takes a perch on the crows nest, and sets about enjoying his spoils!",
			"The crew have appointed the feathered rascal as the ships mascot, and you can't help but smile with them!",
		],

		"failure": [
			"You the bird [color=red]<picked_item_name>[/color], it seems uninterested, and eventually gives up its search and flys back to its rock.",
			"Despite the earlier commotion, the crew seem sad to see them go...",
		],
	},


	"sandbar_a": {
		"required_item": "shovel",
		"intro": [
			"A sandbar has formed from years of costal erosion, and has banked your ship.",
			"You might have something in storage that can help free you!",
		],

		"success": [
			"You poke around in the hold and find the [color=green]<picked_item_name>[/color], and begin digging a path through the shallow sand",
		],

		"failure": [
			"All you could find was a [color=red]<picked_item_name>[/color], it does little to help.\nEventually you order your crew to dig with their bare hands.\nIt takes several hours of grueling work before you're back afloat.",
		],
	},


	"whirlpool_a": {
		"required_item": "seashell",
		"intro": [
			"A violent whirlpool blocks your path.",
			"Could there be anything in your inventory that could possibly help?",
		],

		"success": [
			"You frantically search through your stores, finding nothing that could help. \nIn desperation you throw the first thing you can grab into the whirlpool, a small [color=green]<picked_item_name>[/color] that a salesman promised would bring good fortune.",
			"Within a few moments the whirlpool calms enough to safely pass, and you swear you hear a faint \"thank you\" on the ocean winds...",
		],

		"failure": [
			"All you could think to try was the [color=red]<picked_item_name>[/color], but it does nothing to help. \nYour ship is pulled into the whirlpool, managing to escape after several harrowing hours fighting the current.",
		],
	},


	"storm_a": {
		"required_item": "spare_sail",
		"intro": [
			"A storm has descended upon your ship, and within minutes the winds whip into a frenzy, and a bolt of lightning strikes the main sail.",
			"Surely there's something you could use in its place?",
		],

		"success": [
			"Forethought has meant that you packed a [color=green]<picked_item_name>[/color]\n After a few hours you're back on your way!",
		],

		"failure": [
			"You try to use the [color=red]<picked_item_name>[/color] as a sail, it doesn't really work...\n\nThe crew are despondant, realising that they will now be working twice as hard going forwards.",
		],
	},
}




@export var encounters_list = []
var current_journey_time_encounter:float
var total_encounters:int
var current_encounter:Node
@onready var encounters_container: Node2D = $encounters
var encountered:Array = []





#Groups
@onready var ui_playing: Control = $"CanvasLayer/in-game ui"
@onready var ui_main_menu: Control = $CanvasLayer/main_menu
@onready var ui_loadout: Control = $CanvasLayer/picking_loadout
@onready var ui_pause_menu: Control = $CanvasLayer/pause_menu
@onready var ui_game_over: Control = $CanvasLayer/game_over
@onready var ui_dialogue: Control = $CanvasLayer/dialogue
@onready var ui_win: Control = $CanvasLayer/win
@onready var ui_options: Control = $CanvasLayer/options



@export var ui_groups:Dictionary
@export var ui_morale_icons:Dictionary
@export var ui_health_bar:Dictionary
@export var ui_voyage_bar:Dictionary

var audio_music = AudioServer.get_bus_index("music")
var audio_sfx = AudioServer.get_bus_index("sfx")

var sfx_ows:Array = [
	preload("res://data/sfx/Ow1.mp3"),
	preload("res://data/sfx/Ow2.mp3"),
	preload("res://data/sfx/Ow3.mp3"),
	preload("res://data/sfx/Ow4.mp3"),
	preload("res://data/sfx/Ow5.mp3"),
	preload("res://data/sfx/Ow6.mp3"),
	preload("res://data/sfx/Ow7.mp3"),
]

@onready var waves_a: Sprite2D = $"Waves A"
@onready var waves_b: Sprite2D = $"Waves B"

var config = ConfigFile.new()

func _input(event: InputEvent) -> void:

	if state == states.sailing:
		if Input.is_action_just_pressed("ui_up"):
			if player.current_path > 0:
				player.current_path = player.current_path - 1

		if Input.is_action_just_pressed("ui_down"):
			if player.current_path < 2:
				player.current_path = player.current_path + 1

func _ready() -> void:
	gradient_red_orange_green.add_point(1, Color.RED)
	gradient_red_orange_green.add_point(50, Color.ORANGE)
	gradient_red_orange_green.add_point(100, Color.GREEN)

	events.listen("player_damage", player_damage)

	events.listen("trigger_dialogue", start_dialogue)

	events.listen("win", func win_event(data): state = states.win)

	editor_only_items.visible = false
	config.load("settings")

	ui_sfx_volume.value = config.get_value("settings", "sfx_volume", 0.3)
	ui_music_volume.value = config.get_value("settings", "music_volume", 1)

	AudioServer.set_bus_volume_db(audio_music, linear_to_db(ui_music_volume.value))
	AudioServer.set_bus_volume_db(audio_sfx, linear_to_db(ui_sfx_volume.value))


	ui_groups = {

		"playing": ui_playing,

		"main_menu": ui_main_menu,

		"loadout": ui_loadout,

		"pause_menu": ui_pause_menu,

		"game_over": ui_game_over,

		"dialogue": ui_dialogue,

		"win": ui_win,

		"options": ui_options,
	}

	ui_morale_icons = {
		"happy": ui_happy,
		"ok": ui_ok,
		"sad": ui_sad,
	}

	ui_health_bar = {
		"max": ui_ship_health.size.x,
		"bar": ui_ship_health_current
	}

	ui_voyage_bar = {
		"max": ui_voyage_tracker.size.x - ui_voyage_tracker_current.size.x,
		"bar": ui_voyage_tracker_current
	}

	objects_list_array = []
	for i in objects_list:
		objects_list_array.append(objects_list[i])

	reset_stats()

func _physics_process(delta: float) -> void:

	#runs once when the state is changed
	if last_state != state:

		#sync the last state
		last_state = state

		#clear the ui
		reset_ui()

		match state:
			states.main_menu:
				player.visible = false;
				ui_main_menu.visible = true
				ui_easy_button.grab_focus()
				pass

			states.picking_loadout:
				ui_loadout.visible = true
				ui_first_loadout_button.grab_focus()
				ui_begin_button.disabled = true
				pass

			states.sailing:
				ui_groups.playing.visible = true

			states.in_dialogue:
				ui_groups.dialogue.visible = true

			states.in_event:
				pass

			states.pause_menu:
				pass

			states.highscores:
				pass

			states.game_over:
				game_over()

			states.win:
				win()

			states.options:
				ui_groups.options.visible = true
				ui_sfx_volume.grab_focus()


	#runs every frame
	match state:
		states.main_menu:
			progress += delta * player_speed_menu

		states.new_game:
			progress += delta * player_speed_menu

		states.picking_loadout:
			progress += delta * player_speed_menu
			ui_begin_button.focus_mode = Control.FOCUS_NONE if picked_items.size() < 5 else Control.FOCUS_ALL
			ui_begin_button.disabled = picked_items.size() < 5
			pass

		states.sailing:

			#move the player along
			progress += delta * player_speed


			#update the morale icons
			ui_morale_icons.happy.visible = ship_morale >= 66
			ui_morale_icons.ok.visible = ship_morale >= 33 and ship_morale < 66
			ui_morale_icons.sad.visible = ship_morale < 33


			#update the voyage tracker
			ui_voyage_bar.bar.position.x = (ui_voyage_bar.max *  current_journey_time / journey_time) - 2

			#update the ship health bar
			ui_health_bar.bar.size.x = ui_health_bar.max - (ui_health_bar.max * (1 - (ship_health / _ship_health)))

			#update the health bar colour
			ui_health_bar.bar.color = gradient_red_orange_green.sample((ship_health / _ship_health) * 100)

			roll_for_new_object()

			current_journey_time += delta
			current_journey_time_encounter += delta


			if Input.is_action_just_pressed("pause"):
				state = states.pause_menu
				ui_unpause_button.grab_focus()

			var time_between_encounters = (journey_time / (number_of_encounters + 1))

			#TODO: remove this
			#time_between_encounters = 2

			if current_journey_time_encounter >= time_between_encounters:
				if total_encounters < number_of_encounters:
					create_encounter()
					current_journey_time_encounter = 0
				elif current_journey_time >= selected_journey_time - 1:
					create_shoreline()
					current_journey_time_encounter = 0



			#if current_journey_time >= selected_journey_time:
				#state = states.win

		states.in_dialogue:
			pass

		states.in_event:
			pass

		states.pause_menu:
			ui_pause_menu.visible = true
			if Input.is_action_just_pressed("pause"):
				state = states.sailing
			pass

		states.highscores:
			progress += delta * player_speed_menu

		states.game_over:
			progress += delta * player_speed_menu

	player.position.x = progress + 500
	camera.position.x = progress



	update_waves()
	update_clouds()

func _on_easy_pressed() -> void:
	play_sfx(sfx_ui_click)
	difficulty = difficulties.easy
	new_game()

func _on_normal_pressed() -> void:
	play_sfx(sfx_ui_click)
	difficulty = difficulties.normal
	new_game()

func _on_hard_pressed() -> void:
	play_sfx(sfx_ui_click)
	difficulty = difficulties.hard
	new_game()

func _on_highscores_pressed() -> void:
	play_sfx(sfx_ui_click)
	pass

func _on_return_to_main_menu_button_pressed() -> void:
	play_sfx(sfx_ui_click)
	state = states.main_menu
	clear_objects()
	clear_encounters()


func player_damage(data):
	ship_health += data.ship_damage
	ship_morale += data.morale_damage
	Input.start_joy_vibration(0, 1, 1, 0.2)
	JavaScriptBridge.eval('ShortRumble()')
	player.flashing_time = 0.35
	player.flashing_speed = (player.flashing_time * 10) * 3
	player.flashing_direction = true

	print(111, data.ship_damage)
	if data.ship_damage != 0:
		play_ow()

		player.sprite.texture = player_sprite_1
		await G.wait(200)
		player.sprite.texture = player_sprite_0

	if ship_health <= 0 or ship_morale <= 0:
		player_die()

func reset_ui():
	for i in ui_groups:
		ui_groups[i].visible = false
		pass

func reset_stats():
	ship_health = _ship_health
	ship_morale = _ship_morale
	player_speed = selected_player_speed
	journey_time = selected_journey_time
	player.is_bobbing = true

func roll_for_new_object():

	if player.position.x - last_check_zone > 200:
		last_check_zone = player.position.x

		var roll = randi_range(1, max_roll - last_check_failed) == 1

		if roll:
			last_check_failed = 0
		else:
			last_check_failed += 1


		if roll:
			var new_object = objects_list_array.pick_random().instantiate()
			new_object.position.x = player.position.x + 1400

			var path = randi_range(1, 3)
			if path == 1:
				new_object.position.y = player.path_a.position.y
			elif path == 2:
				new_object.position.y = player.path_b.position.y
			else:
				new_object.position.y = player.path_c.position.y


			objects.add_child(new_object)

func new_game():

	number_of_encounters = number_of_encounters_for_difficulty[difficulty]
	selected_player_speed = player_speeds_for_difficulty[difficulty]
	selected_journey_time = journey_times_for_difficulty[difficulty]
	total_encounters = 0
	encounters_list.clear()
	player.visible = false
	seagull.visible = false
	encountered.clear()
	last_check_zone = 0

	current_journey_time_encounter = 0

	#clear the failed roll counter
	last_check_failed = 0

	current_journey_time = 0

	#reset the players data
	reset_stats()


	player.current_path = player.paths.B

	#place them back at the start position
	#progress = start_progress

	#sync the camera and player positions to the progress
	player.position.x = progress + 500
	camera.position.x = progress

	state = states.picking_loadout

	picked_items.clear()

	clear_objects()
	clear_encounters()

func clear_objects():
	for c in objects.get_children():
		c.visible = false
		objects.remove_child(c)
		c.queue_free()

func clear_encounters():
	pass
	for c in encounters_container.get_children():
		c.visible = false
		encounters_container.remove_child(c)
		c.queue_free()

func begin_game():
	await G.wait(60)
	player.current_path = player.paths.B
	player.instant_path = true;
	player.visible = true;
	state = states.sailing
	play_sfx(sfx_ui_click)

	for item in picked_items:
		encounters_list.append(item.item_encounter)

func game_over():
	ui_groups.game_over.visible = true
	player.visible = false
	clear_objects()
	clear_encounters()
	ui_retry_button.grab_focus()

func win():
	ui_win_text.text = ui_win_text.text.replacen("<encounter_one>", encountered[0].event_script_name)
	ui_win_text.text = ui_win_text.text.replacen("<encounter_two>", encountered[1].event_script_name)
	ui_win_text.text = ui_win_text.text.replacen("<encounter_three>", encountered[2].event_script_name)

	ui_groups.win.visible = true
	player.visible = true
	ui_play_again.grab_focus()

func player_die():
	Input.start_joy_vibration(0, 1, 1, 1)
	JavaScriptBridge.eval('LongRumble()')

	state = states.game_over
	player.is_bobbing = false

func add_item_to_loadout(item:Node):

	if picked_items.has(item):
		picked_items.erase(item)

	elif picked_items.size() < 5:
		picked_items.append(item)

func update_waves():
	var pos = floori(progress / 1280) * 1280
	waves_a.position.x = pos
	waves_b.position.x = pos

func update_clouds():
	var pos = floori(progress / 51200) * 51200
	clouds_1.position.x = pos
	clouds_2.position.x = pos + 51200

func start_dialogue(data):
	current_encounter = data.encounter
	encountered.append(data.encounter)
	ui_dialogue_box.visible = true
	ui_dialogue_item_picker.visible = false
	state = states.in_dialogue
	current_dialogue = dialogue[data.dialogue_name]
	current_dialogue_section = "intro"
	current_dialogue_index = 0
	set_dialogue_text(current_dialogue[current_dialogue_section][current_dialogue_index])

	ui_next_dialogue.grab_focus()
	await G.wait(60)
	ui_next_dialogue.grab_focus()
	await G.wait(60)
	ui_next_dialogue.grab_focus()

func set_dialogue_text(text:String):
	ui_dialogue_text.text = text.replacen("<picked_item_name>", picked_dialogue_item.text if picked_dialogue_item else "")

func _on_next_dialogue_pressed() -> void:
	play_sfx(sfx_ui_click)
	if current_dialogue[current_dialogue_section].get(current_dialogue_index + 1):
		current_dialogue_index += 1
		set_dialogue_text(current_dialogue[current_dialogue_section][current_dialogue_index])
	else:
		match current_dialogue_section:
			"intro":
				ui_dialogue_box.visible = false
				ui_dialogue_item_picker.visible = true

				var items_to_pick_from = []
				var _items_to_pick_from = picked_items.duplicate()

				#check if they have the correct item
				for item in _items_to_pick_from:
					if item.item_name == current_dialogue.required_item:
						items_to_pick_from.append(item)
						_items_to_pick_from.erase(item)
						break

				if items_to_pick_from.size() == 0:

					var item1 = _items_to_pick_from.pick_random()
					if item1:
						items_to_pick_from.append(item1)
						_items_to_pick_from.erase(item1)

					var item2 = _items_to_pick_from.pick_random()
					if item2:
						items_to_pick_from.append(item2)
						_items_to_pick_from.erase(item2)

					var item3 = _items_to_pick_from.pick_random()
					if item3:
						items_to_pick_from.append(item3)
						_items_to_pick_from.erase(item3)

				elif items_to_pick_from.size() == 1:
					var item1 = _items_to_pick_from.pick_random()
					if item1:
						items_to_pick_from.append(item1)
						_items_to_pick_from.erase(item1)

					var item2 = _items_to_pick_from.pick_random()
					if item2:
						items_to_pick_from.append(item2)
						_items_to_pick_from.erase(item2)

				#Randomize the order
				items_to_pick_from.shuffle()

				ui_first_pickable_dialogue_item.visible = true
				ui_first_pickable_dialogue_item.item = items_to_pick_from[0]
				ui_first_pickable_dialogue_item.item_name = items_to_pick_from[0].item_name
				ui_first_pickable_dialogue_item.item_icon = items_to_pick_from[0].item_icon
				ui_first_pickable_dialogue_item.icon = items_to_pick_from[0].item_icon
				ui_first_pickable_dialogue_item.text = items_to_pick_from[0].text
				ui_first_pickable_dialogue_item.grab_focus()

				if items_to_pick_from.size() >= 2:
					ui_second_pickable_dialogue_item.item = items_to_pick_from[1]
					ui_second_pickable_dialogue_item.item_name = items_to_pick_from[1].item_name
					ui_second_pickable_dialogue_item.item_icon = items_to_pick_from[1].item_icon
					ui_second_pickable_dialogue_item.icon = items_to_pick_from[1].item_icon
					ui_second_pickable_dialogue_item.text = items_to_pick_from[1].text
					ui_second_pickable_dialogue_item.visible = true
				else:
					ui_second_pickable_dialogue_item.visible = false

				if items_to_pick_from.size() >= 3:
					ui_third_pickable_dialogue_item.item = items_to_pick_from[2]
					ui_third_pickable_dialogue_item.item_name = items_to_pick_from[2].item_name
					ui_third_pickable_dialogue_item.item_icon = items_to_pick_from[2].item_icon
					ui_third_pickable_dialogue_item.icon = items_to_pick_from[2].item_icon
					ui_third_pickable_dialogue_item.text = items_to_pick_from[2].text
					ui_third_pickable_dialogue_item.visible = true
				else:
					ui_third_pickable_dialogue_item.visible = false


			"success":
				if current_dialogue.get("set_flag_on_success") and current_dialogue.set_flag_on_success == "seagull_mascot":
					current_encounter.sprite_a.visible = false
					seagull.visible = true
				state = states.sailing
				await G.translate(current_encounter, Vector2(current_encounter.position.x, 1280), 10000, "ease_out_back", 118726367182)

			"failure":
				state = states.sailing
				player_damage({"ship_damage":0, "morale_damage":-45})
				await G.translate(current_encounter, Vector2(current_encounter.position.x, 1280), 10000, "ease_out_back", 118726367182)

func dialogue_item_picked(item:Node) -> void:
	picked_items.erase(item)
	picked_dialogue_item = item

	if current_dialogue.required_item == item.item_name:
		current_dialogue_section = "success"
		current_dialogue_index = 0

		set_dialogue_text(current_dialogue[current_dialogue_section][0])
	else:
		current_dialogue_section = "failure"
		current_dialogue_index = 0
		set_dialogue_text(current_dialogue[current_dialogue_section][0])
	ui_dialogue_box.visible = true
	ui_dialogue_item_picker.visible = false
	ui_next_dialogue.grab_focus()
	player_speed += 150

func create_encounter():
	total_encounters += 1

	var new_encoutner = encounters_list.pick_random()
	encounters_list.erase(new_encoutner)
	new_encoutner = new_encoutner.instantiate()
	print("New encoutner created!", " ", new_encoutner)
	encounters_container.add_child(new_encoutner)
	new_encoutner.position.x = progress + 1700
	new_encoutner.position.y = 625.0

func create_shoreline():
	var shore = shoreline.instantiate()
	encounters_container.add_child(shore)
	shore.position.x = progress + 1700
	shore.position.y = 625.0

func _on_restart_button_pressed() -> void:
	play_sfx(sfx_ui_click)
	new_game()

func _on_unpause_button_pressed() -> void:
	play_sfx(sfx_ui_click)
	state = states.sailing


func _on_back_to_main_menu() -> void:
	play_sfx(sfx_ui_click)
	state = states.main_menu

func play_sfx(sfx):
	var player = AudioStreamPlayer.new()
	player.volume_db = config.get_value("settings", "sfx_volume", -12)
	player.bus = "sfx"
	add_child(player)
	player.stream = sfx
	player.play()
	player.connect("finished", func clear_sfx() :
		player.queue_free()
	)

func play_ow():
	sfx_ows.shuffle()
	play_sfx(sfx_ows[0])


func _on_sfx_volume_changed(value:float) -> void:

	config.set_value("settings", "sfx_volume", value)
	AudioServer.set_bus_volume_db(audio_sfx, linear_to_db(value))
	config.save("settings")

func _on_music_volume_changed(value:float) -> void:
	config.set_value("settings", "music_volume", value)
	AudioServer.set_bus_volume_db(audio_music, linear_to_db(value))
	config.save("settings")


func _on_options_pressed() -> void:
	state = states.options
