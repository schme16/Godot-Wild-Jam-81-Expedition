extends CharacterBody2D

enum paths {
	A,
	B,
	C
}

@export var path_a:Node
@export var path_b:Node
@export var path_c:Node
@export var start_path:paths
@export var current_path:paths = paths.B
var path:paths = -1
var last_y_pos
var last_x_pos

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
func _physics_process(delta: float) -> void:

	#Path changed?
	if path != current_path:

		path = current_path

		match current_path:
			paths.A:
				global_position.y = path_a.global_position.y
			paths.B:
				global_position.y = path_b.global_position.y
			paths.C:
				global_position.y = path_c.global_position.y

	#backup the y pos
	last_y_pos = global_position.y
	last_x_pos = global_position.x

	#detect any collisions
	var collisions = move_and_collide(Vector2.ZERO)

	#did we find one?
	if collisions:
		var object = collisions.get_collider()
		if object and object.has_method("invoke") and (!object.trigger_once or (object.trigger_once and !object.has_triggered)):
			object.invoke()

	global_position.x = last_x_pos
	global_position.y = last_y_pos
