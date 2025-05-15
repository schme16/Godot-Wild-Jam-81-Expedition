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

@export var player:PathFollow2D
@onready var clouds: Node2D = $Path2D/Camera/Camera2D/Clouds

@export var camera_follow:PathFollow2D
@export var camera:Camera2D
@export var start_progress:float = 1280
@export var end_progress:float = 198790
@export var progress:float
var start_ratio:float
var max_progress:float

@export var _player_speed:float = 50
var player_speed:float

@export var _ship_health:float = 100
var ship_health:float

@export var _ship_morale:float = 100
var ship_morale:float

@export var state:states
var last_state:states = -1

@onready var ui: Control = $CanvasLayer/UI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	events.listen("player_damage", player_damage)
	pass

func new_game():

	#reset the players data
	reset_stats()

	#place them back at the start position
	progress = start_progress

	player.progress = progress

	camera_follow.progress = progress

	start_ratio = player.progress_ratio

	max_progress = (end_progress - start_progress)


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

				ui.groups.voyage_tracker.visible = true
				ui.groups.ship_health.visible = true
				ui.groups.crew_morale.visible = true
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

			camera_follow.progress = progress
			player.progress = progress
			camera.global_rotation = 0

			#update the morale icons
			ui.morale_icons.happy.visible = ship_morale >= 66
			ui.morale_icons.ok.visible = ship_morale >= 33 and ship_morale < 66
			ui.morale_icons.sad.visible = ship_morale < 33


			#update the voyage tracker
			ui.voyage_bar.bar.position.x = (ui.voyage_bar.max *  player.progress / max_progress) - 2

			#update the ship health bar
			ui.health_bar.bar.size.x = ui.health_bar.max - (ui.health_bar.max * (1 - (ship_health / _ship_health)))

			var grad = Gradient.new()
			grad.add_point(1, Color.RED)
			grad.add_point(50, Color.ORANGE)
			grad.add_point(100, Color.GREEN)


			clouds.global_position.x = 0

			ui.health_bar.bar.color = grad.sample((ship_health / _ship_health) * 100)

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
