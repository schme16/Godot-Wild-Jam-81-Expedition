extends Node

#an easy to grab delta time
@export var delta:float
@export var cancellable_ids = {}




#Game specific stuff





### Funcs ###


func _process(_delta: float) -> void:
	delta = _delta

#Allows you to await by X ms
func wait(milliseconds: float) -> void:
	var seconds = milliseconds/1000
	await get_tree().create_timer(seconds).timeout

#allows you to delay an action by one process frame
func wait_frame() -> void:
	await get_tree().process_frame

##Translates a node to a specified end point (Vector2), can be awaited
#Returns true if it was cancelled
func translate(node, end, duration:float, ease:String, cancellable_id:int = -1):

	#Convert ms to s
	duration = duration / 1000

	#set the initial time value
	var t = 0

	#store the start value
	var startValue = node.position;

	#While the time is less than the duration, and the animation wasn't cancelled
	while t < duration and (!cancellable_ids.has(cancellable_id)  or (cancellable_ids.has(cancellable_id) and cancellable_ids[cancellable_id] == true)):

		#Set the angle
		node.position = startValue.lerp(end, easing[ease].call(0, 1, t / duration if t > 0 else 0 ))

		# Wait for the next frame
		await wait_frame()

		#Update the time value
		t = clamp(t + delta, 0, duration)

	#Was this aniamtion cancelled?
	if (cancellable_ids.has(cancellable_id) and cancellable_ids[cancellable_id] == true):

		#Clear the cancellable id
		cancellable_ids.erase(cancellable_id)

		#return true to indicate that it was cancelled
		return true

	#Wasn't cancelled
	else:

		#Set the final position (just in case it was over/under above
		node.position = end;

		#return false to show itr wasn't cancelled
		return false

##Rotates a node to a specified Vector2/3, can be awaited
#Returns true if it was cancelled
func rotate(node, end, duration, ease:String, cancellable_id:int = -1):

	#Convert ms to s
	duration = duration / 1000

	#set the initial time value
	var t = 0

	#store the start value
	var startValue = node.rotation_degrees;

	#While the time is less than the duration, and the animation wasn't cancelled
	while t < duration and (!cancellable_ids.has(cancellable_id)  or (cancellable_ids.has(cancellable_id) and cancellable_ids[cancellable_id] == true)):

		#Set the angle
		if type_string(typeof(node)) == "Node2D":
			node.rotation_degrees = lerp(startValue, end, easing[ease].call(0, 1, t / duration if t > 0 else 0 ))
		else:
			node.rotation_degrees = startValue.lerp(end, easing[ease].call(0, 1, t / duration if t > 0 else 0 ))


		# Wait for the next frame
		await wait_frame()

		#Update the time value
		t = clamp(t + delta, 0, duration)

	#Was this aniamtion cancelled?
	if (cancellable_ids.has(cancellable_id) and cancellable_ids[cancellable_id] == true):

		#Clear the cancellable id
		cancellable_ids.erase(cancellable_id)

		#return true to indicate that it was cancelled
		return true

	#Wasn't cancelled
	else:

		#Set the final position (just in case it was over/under above
		node.rotation_degrees = end;

		#return false to show itr wasn't cancelled
		return false

##Scales a node to a specified Vector2/3, can be awaited
#Returns true if it was cancelled
func scale(node, end, duration:float, ease:String, cancellable_id:int = -1):

	#Convert ms to s
	duration = duration / 1000

	#set the initial time value
	var t = 0

	#store the start value
	var startValue = node.scale;

	#While the time is less than the duration, and the animation wasn't cancelled
	while t < duration and (!cancellable_ids.has(cancellable_id)  or (cancellable_ids.has(cancellable_id) and cancellable_ids[cancellable_id] == true)):

		#Set the angle
		node.scale = startValue.lerp(end, easing[ease].call(0, 1, t / duration if t > 0 else 0 ))

		# Wait for the next frame
		await wait_frame()

		#Update the time value
		t = clamp(t + delta, 0, duration)

	#Was this aniamtion cancelled?
	if (cancellable_ids.has(cancellable_id) and cancellable_ids[cancellable_id] == true):

		#Clear the cancellable id
		cancellable_ids.erase(cancellable_id)

		#return true to indicate that it was cancelled
		return true

	#Wasn't cancelled
	else:

		#Set the final position (just in case it was over/under above
		node.scale = end;

		#return false to show itr wasn't cancelled
		return false
