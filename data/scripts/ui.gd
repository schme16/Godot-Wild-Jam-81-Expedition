extends Control
@onready var voyage_tracker: Control = $playing/voyage_tracker
@onready var voyage_tracker_current: ColorRect = $playing/voyage_tracker/current

@onready var ship_health: Control = $playing/ship_health
@onready var ship_health_current: ColorRect = $playing/ship_health/current


@onready var crew_morale: Control = $playing/crew_morale
@onready var happy: Sprite2D = $playing/crew_morale/happy
@onready var ok: Sprite2D = $playing/crew_morale/ok
@onready var sad: Sprite2D = $playing/crew_morale/sad


#Groups
@onready var playing: Control = $playing
@onready var game_over: Control = $game_over
@onready var pause_menu: Control = $pause_menu
@onready var start_menu: Control = $start_menu
@onready var loadout: Control = $loadout





@export var groups:Dictionary
@export var morale_icons:Dictionary
@export var health_bar:Dictionary
@export var voyage_bar:Dictionary


func _ready() -> void:
	groups = {
		#"voyage_tracker": voyage_tracker,
		#"ship_health": ship_health,
		#"crew_morale": crew_morale,

		"playing": playing,

		"game_over": game_over,

		"pause_menu": pause_menu,

		"start_menu": start_menu,

		"loadout": loadout,
	}

	morale_icons = {
		"happy": happy,
		"ok": ok,
		"sad": sad,
	}

	health_bar = {
		"max": ship_health.size.x,
		"bar": ship_health_current
	}

	voyage_bar = {
		"max": voyage_tracker.size.x - voyage_tracker_current.size.x,
		"bar": voyage_tracker_current
	}
