extends Position2D

# The camera_distance_multiplyer is multiplyed by the player movement to 
# make the camera go in front of the player as they are moveing.
var camera_distance_multiplyer = 0.5
onready var parent = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	update_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	update_position()

func update_position():
	position = parent.movement * camera_distance_multiplyer
