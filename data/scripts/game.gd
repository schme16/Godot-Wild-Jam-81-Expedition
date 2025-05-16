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
}

@export var player:Node2D
@onready var clouds: Node2D = $Clouds
@export var camera:Camera2D
@export var start_progress:float = 0
@export var journey_time_easy:float = 180
@export var journey_time_normal:float = 360
@export var journey_time_hard:float = 720
var journey_time:float
var end_progress:float
@export var progress:float
@export var editor_only_items:Node2D
var start_ratio:float
var max_progress:float

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
@export var picked_items_ids:Array

var last_check_zone:float
var last_check_failed:int
var current_journey_time:float


@onready var objects_list: Dictionary = {
	"rock": preload("res://data/prefabs/rock.tscn"),
	"shark": preload("res://data/prefabs/shark_fin.tscn")
}

@onready var objects: Node2D = $"objects"






#ui stuff
@onready var ui_easy_button: Button = $CanvasLayer/main_menu/Panel/VBoxContainer2/VBoxContainer/Easy
@onready var ui_first_loadout_button: Button = $"CanvasLayer/picking_loadout/Panel/MarginContainer/VBoxContainer/HBoxContainer/items list/item3"
@onready var ui_begin_button: Button = $"CanvasLayer/picking_loadout/Panel/MarginContainer/VBoxContainer/MarginContainer/Begin button"


@onready var ui_voyage_tracker: Control = $"CanvasLayer/in-game ui/voyage_tracker"
@onready var ui_voyage_tracker_current: ColorRect = $"CanvasLayer/in-game ui/voyage_tracker/current"

@onready var ui_ship_health: Control = $"CanvasLayer/in-game ui/ship_health"
@onready var ui_ship_health_current: ColorRect = $"CanvasLayer/in-game ui/ship_health/current"


@onready var ui_crew_morale: Control = $"CanvasLayer/in-game ui/crew_morale"
@onready var ui_happy: Sprite2D = $"CanvasLayer/in-game ui/crew_morale/happy"
@onready var ui_ok: Sprite2D = $"CanvasLayer/in-game ui/crew_morale/ok"
@onready var ui_sad: Sprite2D = $"CanvasLayer/in-game ui/crew_morale/sad"




#Groups
@onready var ui_playing: Control = $"CanvasLayer/in-game ui"
@onready var ui_main_menu: Control = $CanvasLayer/main_menu
@onready var ui_loadout: Control = $CanvasLayer/picking_loadout
@onready var ui_pause_menu: Control = $CanvasLayer/pause_menu





@export var ui_groups:Dictionary
@export var ui_morale_icons:Dictionary
@export var ui_health_bar:Dictionary
@export var ui_voyage_bar:Dictionary







func _input(event: InputEvent) -> void:

	if Input.is_action_just_pressed("ui_up"):
		if player.current_path > 0:
			player.current_path = player.current_path - 1

	if Input.is_action_just_pressed("ui_down"):
		if player.current_path < 2:
			player.current_path = player.current_path + 1



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gradient_red_orange_green.add_point(1, Color.RED)
	gradient_red_orange_green.add_point(50, Color.ORANGE)
	gradient_red_orange_green.add_point(100, Color.GREEN)

	events.listen("player_damage", player_damage)
	editor_only_items.visible = false

	ui_groups = {
		#"voyage_tracker": voyage_tracker,
		#"ship_health": ship_health,
		#"crew_morale": crew_morale,

		"playing": ui_playing,

		"main_menu": ui_main_menu,

		"loadout": ui_loadout,

		"pause_menu": ui_pause_menu,

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
				pass

			states.in_dialogue:
				pass

			states.in_event:
				pass

			states.pause_menu:
				pass

			states.highscores:
				pass

			states.game_over:
				game_over()
				pass

	#runs every frame
	match state:
		states.main_menu:
			pass

		states.new_game:
			pass

		states.picking_loadout:
			ui_begin_button.focus_mode = Control.FOCUS_NONE if picked_items.size() < 5 else Control.FOCUS_ALL
			ui_begin_button.disabled = picked_items.size() < 5
			pass

		states.sailing:

			#move the player along
			progress += delta * player_speed

			camera.position.x = progress
			player.position.x = progress + 500

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

			if Input.is_action_just_pressed("pause"):
				state = states.pause_menu

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
			pass

		states.game_over:
			pass

func _on_easy_pressed() -> void:

	new_game(journey_time_easy)

func _on_normal_pressed() -> void:

	new_game(journey_time_normal)

func _on_hard_pressed() -> void:

	new_game(journey_time_hard)

func _on_highscores_pressed() -> void:
	pass

func player_damage(data) :
	print(data)
	ship_health += data.ship_damage
	ship_morale += data.morale_damage
	Input.start_joy_vibration(0, 1, 1, 0.2)
	if ship_health <= 0 or ship_morale <= 0:
		player_die()


func reset_ui():
	for i in ui_groups:
		ui_groups[i].visible = false
		pass

func reset_stats():
	ship_health = _ship_health
	ship_morale = _ship_morale
	player_speed = _player_speed

func roll_for_new_object():

	if player.position.x - last_check_zone > 200:
		last_check_zone = player.position.x

		var roll = randi_range(1, max_roll - last_check_failed) == 1
		print("Roll: ", roll)


		if roll:
			last_check_failed = 0
		else:
			last_check_failed += 1


		if roll:
			var new_object = objects_list.rock.instantiate()
			new_object.position.x = player.position.x + 1400
			var path = randi_range(1, 3)
			if path == 1:
				new_object.position.y = player.path_a.position.y
			elif path == 2:
				new_object.position.y = player.path_b.position.y
			else:
				new_object.position.y = player.path_c.position.y


			objects.add_child(new_object)

			print("Rock!")

func new_game(game_length:int):

	last_check_zone = 0

	#reset the players data
	reset_stats()

	#place them back at the start position
	progress = start_progress

	#sync the camera and player positions to the progress
	player.position.x = progress + 500
	camera.position.x = progress

	#clear the failed roll counter
	last_check_failed = 0

	current_journey_time = 0

	journey_time = game_length

	state = states.picking_loadout

	picked_items.clear()
	picked_items_ids.clear()

	for c in objects.get_children():
		c.visible = false
		objects.remove_child(c)
		c.queue_free()

func begin_game():
	player.visible = true;
	state = states.sailing

func game_over():
	state = states.main_menu

func player_die():
	Input.start_joy_vibration(0, 1, 1, 1)
	state = states.game_over

func add_item_to_loadout(id, text):

	if picked_items_ids.has(id):
		picked_items_ids.erase(id)
		picked_items.erase(text)

	elif picked_items.size() < 5:
		picked_items_ids.append(id)
		picked_items.append(text)
