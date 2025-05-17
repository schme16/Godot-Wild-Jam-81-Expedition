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
@export var y_pos:float
var last_y_pos
var last_x_pos
@onready var sprite: Sprite2D = $sprite
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var game: Node2D = $".."

@export var is_bobbing:bool
@export var flashing_time:float
@export var flashing_speed:float = 1
var flashing_direction:bool = true
var flash_value:float = 0


@export var instant_path:bool
var bobbing_up:bool
var bob_height:int
func _ready() -> void:
	match current_path:
		paths.A:
			y_pos = path_a.global_position.y
		paths.B:
			y_pos = path_b.global_position.y
		paths.C:
			y_pos = path_c.global_position.y

	global_position.y = y_pos
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	#Path changed?
	if path != current_path:

		path = current_path

		match current_path:
			paths.A:
				y_pos = path_a.global_position.y
			paths.B:
				y_pos = path_b.global_position.y
			paths.C:
				y_pos = path_c.global_position.y

	if !instant_path:
		global_position.y = lerpf(global_position.y, y_pos, delta * 5)
	else:
		instant_path = false
		global_position.y = y_pos


	if is_bobbing:
		if bobbing_up:
			sprite.position.y -= delta * 10
			if sprite.position.y <= -(bob_height):
				bobbing_up = false
				bob_height = randi_range(1, 15)
		else:
			sprite.position.y += delta * 5
			if sprite.position.y >= bob_height:
				bobbing_up = true

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

	if flashing_time > 0:
		flashing_time -= delta

		if flashing_direction:
			flash_value += delta * flashing_speed

			if flash_value >= 1:
				flashing_direction = false
		else:
			flash_value -= delta * flashing_speed
			if flash_value <=0:
				flashing_direction = true

	elif flash_value > 0:
		flash_value -= delta * flashing_speed

	elif flash_value < 0:
		flash_value = 0

	sprite.material.set_shader_parameter("fade", flash_value)
