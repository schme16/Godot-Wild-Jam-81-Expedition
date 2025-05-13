extends PathFollow2D

enum paths {
	A,
	B,
	C
}

@export var path_a:Node
@export var path_b:Node
@export var path_c:Node
@export var start_path:paths
@onready var character_body_2d: CharacterBody2D = $CharacterBody2D

@export var current_path:paths = paths.B
var path:paths = -1


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("up"):
			if current_path > 0:
				current_path = current_path - 1

		if Input.is_action_just_pressed("down"):
			if current_path < 2:
				current_path = current_path + 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if path != current_path:
		path = current_path

		match current_path:
			paths.A:
				character_body_2d.position.y = path_a.position.y
			paths.B:
				character_body_2d.position.y = path_b.position.y
			paths.C:
				character_body_2d.position.y = path_c.position.y
