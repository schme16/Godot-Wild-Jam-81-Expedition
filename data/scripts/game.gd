extends Node2D

@export var player:PathFollow2D
@export var camera_follow:PathFollow2D
@export var camera:Camera2D
@export var progress:float = 0.0061



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player.progress_ratio = progress
	camera_follow.progress_ratio = progress
