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
@export var journey_time:float = 180
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

@onready var ui: Control = $CanvasLayer/UI
var gradient_red_orange_green = Gradient.new()

@export var max_roll:int = 7

var last_check_zone:float
var last_check_failed:int
var current_journey_time:float


@onready var objects_list: Dictionary = {
	"rock": preload("res://data/prefabs/rock.tscn"),
	"shark": preload("res://data/prefabs/shark_fin.tscn")
}

@onready var objects: Node2D = $"objects"




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gradient_red_orange_green.add_point(1, Color.RED)
	gradient_red_orange_green.add_point(50, Color.ORANGE)
	gradient_red_orange_green.add_point(100, Color.GREEN)

	events.listen("player_damage", player_damage)
	editor_only_items.visible = false
	pass

func new_game():

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

func reset_stats():
	ship_health = _ship_health
	ship_morale = _ship_morale
	player_speed = _player_speed


func _physics_process(delta: float) -> void:

	#runs once when the state is changed
	if last_state != state:

		#sync the last state
		last_state = state

		#clear the ui
		ResetUI()

		match state:
			states.main_menu:
				pass

			states.new_game:
				new_game()
				pass

			states.picking_loadout:
				pass

			states.sailing:

				#TODO: Ramove this after the menu is made
				new_game()

				ui.groups.playing.visible = true
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
				pass

	#runs every frame
	match state:
		states.main_menu:
			pass

		states.new_game:
			pass

		states.picking_loadout:
			pass

		states.sailing:

			#move the player along
			progress += delta * player_speed

			camera.position.x = progress
			player.position.x = progress + 500

			#update the morale icons
			ui.morale_icons.happy.visible = ship_morale >= 66
			ui.morale_icons.ok.visible = ship_morale >= 33 and ship_morale < 66
			ui.morale_icons.sad.visible = ship_morale < 33


			#update the voyage tracker
			ui.voyage_bar.bar.position.x = (ui.voyage_bar.max *  current_journey_time / journey_time) - 2

			#update the ship health bar
			ui.health_bar.bar.size.x = ui.health_bar.max - (ui.health_bar.max * (1 - (ship_health / _ship_health)))

			#update the health bar colour
			ui.health_bar.bar.color = gradient_red_orange_green.sample((ship_health / _ship_health) * 100)

			roll_for_new_object()

			current_journey_time += delta


		states.in_dialogue:
			pass

		states.in_event:
			pass

		states.pause_menu:
			pass

		states.highscores:
			pass

		states.game_over:
			pass

func player_damage(data) :
	print(data)
	ship_health += data.ship_damage
	ship_morale += data.morale_damage

func ResetUI():
	for i in ui.groups:
		ui.groups[i].visible = false
		pass

func game_over():
	ResetUI()
	ui.groups.game_over.visible = true


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
