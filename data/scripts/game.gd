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
}

@export var player:Node2D
@onready var clouds_1: Node2D = $"Clouds 1"
@onready var clouds_2: Node2D = $"Clouds 2"

@export var camera:Camera2D
@export var number_of_encounters:float = 0
@export var number_of_encounters_easy:float = 3
@export var number_of_encounters_normal:float = 3
@export var number_of_encounters_hard:float = 4
@export var start_progress:float = 0
#@export var journey_time_easy:float = 180
#TODO: remove
@export var journey_time_easy:float = 30
@export var journey_time_normal:float = 360
@export var journey_time_hard:float = 720
@export var selected_journey_time:float = 180
var journey_time:float
@export var progress:float
@export var editor_only_items:Node2D


@export var player_speed_easy:float = 250
@export var player_speed_normal:float = 350
@export var player_speed_hard:float = 500
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






#ui stuff
@onready var ui_easy_button: Button = $CanvasLayer/main_menu/Panel/VBoxContainer2/VBoxContainer/Easy
@onready var ui_first_loadout_button: Button = $"CanvasLayer/picking_loadout/Panel/MarginContainer/VBoxContainer/HBoxContainer/items list/item3"
@onready var ui_begin_button: Button = $"CanvasLayer/picking_loadout/Panel/MarginContainer/VBoxContainer/MarginContainer/Begin button"
@onready var ui_retry_button: Button = $CanvasLayer/game_over/Panel/VBoxContainer2/VBoxContainer/Retry
@onready var ui_unpause_button: Button = $"CanvasLayer/pause_menu/Panel/VBoxContainer2/Unpause button"
@onready var ui_play_again: Button = $"CanvasLayer/win/Panel/VBoxContainer2/VBoxContainer/Play again"

@onready var ui_voyage_tracker: Control = $"CanvasLayer/in-game ui/voyage_tracker"
@onready var ui_voyage_tracker_current: ColorRect = $"CanvasLayer/in-game ui/voyage_tracker/current"

@onready var ui_ship_health: Control = $"CanvasLayer/in-game ui/ship_health"
@onready var ui_ship_health_current: ColorRect = $"CanvasLayer/in-game ui/ship_health/current"


@onready var ui_crew_morale: Control = $"CanvasLayer/in-game ui/crew_morale"
@onready var ui_happy: Sprite2D = $"CanvasLayer/in-game ui/crew_morale/happy"
@onready var ui_ok: Sprite2D = $"CanvasLayer/in-game ui/crew_morale/ok"
@onready var ui_sad: Sprite2D = $"CanvasLayer/in-game ui/crew_morale/sad"






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
			"\n[font_size=5]\n[/font_size][center]Quick, pick an item![/center]",


		],

		"success": [
			"You toss over the [color=green]<picked_item_name>[/color] over the side and the seal leaps after the free snack. \nThe crew member shakily gets to his feet, relieved.",
			"Now let's get out of here!",
		],

		"failure": [
			"You attempt to use the [color=red]<picked_item_name>[/color] on the seal. \nThe seal seems unbothered by your actions and continues roll on the crew member. \nIt eventually loses interest and galomphs away and off the boat, but not before the breaking the poor man's legs. He is not happy."
		],
	}
}




#encounter stuff
var encounters = [
	preload("res://data/prefabs/encounter_sea_doggo.tscn")
]
var current_journey_time_encounter:float
var current_encounter:Node
@onready var encounters_container: Node2D = $encounters






#Groups
@onready var ui_playing: Control = $"CanvasLayer/in-game ui"
@onready var ui_main_menu: Control = $CanvasLayer/main_menu
@onready var ui_loadout: Control = $CanvasLayer/picking_loadout
@onready var ui_pause_menu: Control = $CanvasLayer/pause_menu
@onready var ui_game_over: Control = $CanvasLayer/game_over
@onready var ui_dialogue: Control = $CanvasLayer/dialogue
@onready var ui_win: Control = $CanvasLayer/win



@export var ui_groups:Dictionary
@export var ui_morale_icons:Dictionary
@export var ui_health_bar:Dictionary
@export var ui_voyage_bar:Dictionary


@onready var waves_a: Sprite2D = $"Waves A"
@onready var waves_b: Sprite2D = $"Waves B"


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

	editor_only_items.visible = false

	ui_groups = {

		"playing": ui_playing,

		"main_menu": ui_main_menu,

		"loadout": ui_loadout,

		"pause_menu": ui_pause_menu,

		"game_over": ui_game_over,

		"dialogue": ui_dialogue,

		"win": ui_win,
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
				create_encounter()
				current_journey_time_encounter = 0

			if current_journey_time >= selected_journey_time:
				state = states.win

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
	number_of_encounters = number_of_encounters_easy
	selected_player_speed = player_speed_easy
	selected_journey_time = journey_time_easy
	new_game()

func _on_normal_pressed() -> void:
	number_of_encounters = number_of_encounters_normal
	selected_player_speed = player_speed_normal
	selected_journey_time = journey_time_normal
	new_game()

func _on_hard_pressed() -> void:
	number_of_encounters = number_of_encounters_hard
	selected_player_speed = player_speed_hard
	selected_journey_time = journey_time_hard
	new_game()

func _on_highscores_pressed() -> void:
	pass

func _on_return_to_main_menu_button_pressed() -> void:
	state = states.main_menu
	clear_objects()

func player_damage(data):
	ship_health += data.ship_damage
	ship_morale += data.morale_damage
	Input.start_joy_vibration(0, 1, 1, 0.2)
	JavaScriptBridge.eval('ShortRumble()')
	player.flashing_time = 0.35
	player.flashing_speed = (player.flashing_time * 10) * 3
	player.flashing_direction = true

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

func clear_objects():
	for c in objects.get_children():
		c.visible = false
		objects.remove_child(c)
		c.queue_free()

func begin_game():
	player.current_path = player.paths.B
	player.instant_path = true;
	player.visible = true;
	state = states.sailing

func game_over():
	ui_groups.game_over.visible = true
	player.visible = false
	clear_objects()
	ui_retry_button.grab_focus()


func win():
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
	ui_dialogue_box.visible = true
	ui_dialogue_item_picker.visible = false
	state = states.in_dialogue
	current_dialogue = dialogue[data.dialogue_name]
	ui_next_dialogue.grab_focus()
	current_dialogue_section = "intro"
	current_dialogue_index = 0
	set_dialogue_text(current_dialogue[current_dialogue_section][current_dialogue_index])

func set_dialogue_text(text:String):
	ui_dialogue_text.text = text.replacen("<picked_item_name>", picked_dialogue_item.text if picked_dialogue_item else "")

func _on_next_dialogue_pressed() -> void:
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
				state = states.sailing
				await G.translate(current_encounter, Vector2(current_encounter.position.x, 1280), 10000, "ease_out_back", 118726367182)

			"failure":
				state = states.sailing
				player_damage({"ship_damage":0, "morale_damage":-36})
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
	var new_encoutner = encounters.pick_random().instantiate()
	print("New encoutner created!", " ", new_encoutner)
	encounters_container.add_child(new_encoutner)
	new_encoutner.position.x = progress + 1500
	new_encoutner.position.y = 625.0

func _on_restart_button_pressed() -> void:
	new_game()

func _on_unpause_button_pressed() -> void:
	state = states.sailing
