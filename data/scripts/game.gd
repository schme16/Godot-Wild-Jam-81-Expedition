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

@onready var ui: Control = $CanvasLayer/UI


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
			
			player.progress = progress
			camera_follow.progress = progress
	
			#update the morale icons
			ui.morale_icons.happy.visible = ship_morale >= 66
			ui.morale_icons.ok.visible = ship_morale >= 33 and ship_morale < 66
			ui.morale_icons.sad.visible = ship_morale < 33
			
			#update the voyage tracker
			ui.voyage_bar.bar.position.x = ui.voyage_bar.max * player.progress_ratio
			
			#update the ship health bar
			ui.health_bar
			
			

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



func ResetUI():
	for i in ui.groups:
		ui.groups[i].visible = false
		pass
