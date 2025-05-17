extends Button


@export var item_id:int = get_instance_id()
@export var item_name:String
@export var item_icon:Texture2D

@onready var game: Node2D = $"../../../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = item_name if !item_name.is_empty() else text
	icon = item_icon

func _pressed() -> void:
	game.dialogue_item_picked(self, item_id, item_name, item_icon)
