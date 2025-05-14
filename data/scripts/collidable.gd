@tool
extends Node

enum modes {
	set_dressing,
	obstacle,
	trigger_dialogue,
	trigger_event
}

##Should this trigger just once?
#Default: true
@export var trigger_once:bool = true

@export var mode : modes :
	set(value):
		mode = value
		notify_property_list_changed()

##The name of the event to trigger on collision
@export var event_name:String

##The name of the dialogue to trigger on collision
@export var dialogue_name:String

##How much damage to take on impact
@export var ship_damage:float

##How much morale damage to take on impact
@export var morale_damage:float

##Will a random item be lost on collision?
@export var lose_items_on_impact:int

var has_triggered:bool = false

#Show/hides export variables based on the selected mode
func _validate_property(property: Dictionary) -> void:

	var set_dressing_test = [
		"event_name",
		"dialogue_name",
		"ship_damage",
		"morale_damage",
		"lose_items_on_impact",
	].find(property.name) > -1

	var obstacle_test = [
		"ship_damage",
		"morale_damage",
		"lose_items_on_impact",
	].find(property.name) > -1

	var trigger_dialogue_test = [
		"dialogue_name"
	].find(property.name) > -1

	var trigger_event_test = [
		"event_name"
	].find(property.name) > -1


	var test = set_dressing_test || obstacle_test || trigger_dialogue_test || trigger_event_test

	if test:
		match mode:
			modes.set_dressing:
				property.usage = PROPERTY_USAGE_NO_EDITOR

			modes.obstacle:
				if obstacle_test:
					property.usage = PROPERTY_USAGE_DEFAULT
				else:
					property.usage = PROPERTY_USAGE_NO_EDITOR


				pass

			modes.trigger_dialogue:
				if trigger_dialogue_test:
					property.usage = PROPERTY_USAGE_DEFAULT
				else:
					property.usage = PROPERTY_USAGE_NO_EDITOR


				pass

			modes.trigger_event:
				if trigger_event_test:
					property.usage = PROPERTY_USAGE_DEFAULT
				else:
					property.usage = PROPERTY_USAGE_NO_EDITOR


				pass

			_: property.usage = PROPERTY_USAGE_DEFAULT

	else:
		property.usage = property.usage

#The function to run when colliding
func invoke():
	if !has_triggered or !trigger_once:

		has_triggered = true

		match mode:
			modes.set_dressing:
				print("I'm just set dressing")

			modes.obstacle:
				if ship_damage > 0 or morale_damage > 0:
					events.invoke("player_damage", {
						ship_damage: ship_damage,
						morale_damage: morale_damage
					})

				if lose_items_on_impact > 0:
					events.invoke("player_lose_item", {
						lose_items_on_impact: lose_items_on_impact
					})

			modes.trigger_dialogue:
				events.invoke("trigger_dialogue", {
					dialogue_name: dialogue_name
				})

			modes.trigger_event:
				events.invoke("trigger_event", {
					event_name: event_name
				})
