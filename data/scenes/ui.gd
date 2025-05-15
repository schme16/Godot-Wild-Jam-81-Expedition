extends Control
@onready var voyage_tracker: Control = $voyage_tracker
@onready var voyage_tracker_current: ColorRect = $voyage_tracker/current

@onready var ship_health: Control = $ship_health
@onready var ship_health_current: ColorRect = $ship_health/current


@onready var crew_morale: Control = $crew_morale
@onready var happy: Sprite2D = $crew_morale/happy
@onready var ok: Sprite2D = $crew_morale/ok
@onready var sad: Sprite2D = $crew_morale/sad

@export var groups:Dictionary
@export var morale_icons:Dictionary
@export var health_bar:Dictionary
@export var voyage_bar:Dictionary


func _ready() -> void:
	groups = {
		"voyage_tracker": voyage_tracker,
		"ship_health": ship_health,
		"crew_morale": crew_morale,
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
		"max": voyage_tracker.size.x,
		"bar": voyage_tracker_current
	}
	
	
