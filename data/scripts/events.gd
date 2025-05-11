extends Node

var events_lookup = {}

##Listen to a fireable event
func listen(event_name:String, event_function:Callable):

	#Event name not set
	if !events_lookup.has(event_name):

		#Set it to an empty dict
		events_lookup[event_name] = {}

	#Get the id
	var id = event_function.get_object_id()

	#set the function to the event name uner its id
	events_lookup[event_name][id] = event_function

	#hand back the id
	return id

## Stop listening to an event
func unlisten(event_name:String, event_id:int):

	#Does the even name, and event id exist and are set?
	if events_lookup.has(event_name) and events_lookup[event_name].has(event_id):

		#Delete the function from the dict
		events_lookup[event_name].erase(event_id)

	#Missing the event name?
	elif !events_lookup.has(event_name) :

		#log the error
		print("Unlisten error - No event called: ", event_name)

	#Missing the event id?
	elif !events_lookup[event_name].has(event_id):

		#log the error
		print("Unlisten error - No event id: ", event_id)


##Fire all listeners for a ggeven event name, with the specified data
func invoke(event_name, data):

	#Data wasn't specified?
	if !data:

		#set it to an empty dict
		data = {}

	#Does the event name exist?
	if events_lookup.has(event_name):

		#Go over all entries for that even name
		for key in events_lookup[event_name].keys():

			#set the event id for this specific entry
			data.event_id = key

			#call the event
			events_lookup[event_name][key].call(data)

	#Event doesn't exist?
	else:

		#log the error
		print("Invoke error - No event called: ", event_name)
