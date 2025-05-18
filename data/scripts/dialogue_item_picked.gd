extends Button


@export var item_id:int = get_instance_id()
@export var item_name:String
@export var item_icon:Texture2D
@export var item:Node

@onready var game: Node2D = $"../../../../.."


func _pressed() -> void:
	game.dialogue_item_picked(item)
	game.play_sfx(game.sfx_ui_click)
