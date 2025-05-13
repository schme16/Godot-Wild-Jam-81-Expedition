##This makes the Line2D that it's attached to render its Path2D parent
@tool
extends Line2D

##Forces an update
@export var force_update:bool

##The path 2d that we want to render
@export var path_2d:Path2D

#The path2d curve that we want to render
var curve:Curve2D

##The precission level
@export var point_precision:int = 50

func _ready():

	#render the points on start
	update_points()


func _process(delta):

	#is the current curve is different from the attached curve, or we're forcing an update
	if curve != path_2d.curve or force_update:
		#render the points
		update_points()


##Updates the points to render
func update_points():

	#turn off the force update
	force_update = false

	#set the curve
	curve = path_2d.curve

	#clear the points
	var new_points = []

	#if the curve is set
	if curve:

		#Get the total length of the curve
		var length = curve.get_baked_length()

		#Determine sample count based on curve complexity
		var sample_count = int(length / point_precision)

		#Ensure minimum sample count
		sample_count = max(sample_count, 20)

		#Sample points along the curve at equal distances
		for i in range(sample_count + 1):

			#Create a new point and add it to the array
			new_points.append(curve.sample_baked(i * length / sample_count))

		points = new_points
