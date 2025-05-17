extends Button

@export var item_id:int = get_instance_id()
@export var item_name:String
@export var item_icon:Texture2D
@onready var game: Node2D = $"../../../../../../../.."

var picked_icon = preload("res://data/textures/icons/item-selected.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = item_name if !item_name.is_empty() else text
	item_icon = icon

func _process(delta: float) -> void:

	if game.picked_items_ids.has(item_id):
		icon = picked_icon
	else:
		icon = item_icon

	if game.picked_items_ids.size() >=5 and !game.picked_items_ids.has(item_id):
		disabled = true
		focus_mode = Control.FOCUS_NONE
	else:
		disabled = false
		focus_mode = Control.FOCUS_ALL

func _pressed() -> void:
	game.add_item_to_loadout(item_id, item_name)
