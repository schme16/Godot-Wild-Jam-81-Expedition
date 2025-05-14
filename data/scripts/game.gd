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
@export var camera_follow:PathFollow2D
@export var camera:Camera2D
@export var progress:float = 1200

@export var _player_speed:float = 50
var player_speed:float

@export var _ship_health:float = 100
var ship_health:float

@export var _ship_morale:float = 100
var ship_morale:float

@export var state:states
var last_state:states = -1



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_stats()
	pass

func new_game():
	reset_stats()
	pass

func reset_stats():
	ship_health = _ship_health
	ship_morale = _ship_morale
	player_speed = _player_speed


func _process(delta: float) -> void:

	#runs once when the state is changed
	if last_state != state:
		last_state = state

		match state:
			states.main_menu:
				pass

			states.new_game:
				new_game()
				pass

			states.picking_loadout:
				pass

			states.sailing:
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
			print(progress, " ", delta * player_speed)
			progress += delta * player_speed
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

	player.progress = progress
	camera_follow.progress = progress
