# inherits from KinematicBody2D
extends KinematicBody2D

# vars for movement properties
var accel = 20 				# How fast the player accelerates (orig. 15)
var decel = 25				# How fast the player decelerates (orig. 30)
var max_speed = 700			# Max speed the player can move
var min_speed = 0			# Minimum speed the player can move

# vars for runtime
var velocity = 0
var movement = Vector2.ZERO
var drag = false
var health_points = 100

# var created when _ready called
# "$" is a way to get node in the same scene
onready var animate_player = $PlayerAnimator

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Spawned: Player with ", health_points, "hp.")


# Runs every frame
func _physics_process(_delta):
	# get mouse pos and set next movement
	var pos = get_global_mouse_position()
	movement = pos - position
	
	# if click and movement non-zero, accelerate
	if (drag and movement != Vector2.ZERO):
		# play walkright if movement is positive x, else walkleft
		if movement.x > 0:
			animate_player.play("WalkRight")
		else:
			animate_player.play("WalkLeft")
		accelerate(accel)
	else:
		animate_player.play("IdleLeft")
		decelerate(decel)
		
	# stop player if they slow enough
	if velocity < accel:
		velocity = 0
		
	# normalize movement and add new velocity
	if (movement.length() > velocity):
		movement = velocity * movement.normalized()
		
	# apply movement using slide, which doesn't need delta!
	# returns R2 vector after collision
	movement = move_and_slide(movement)


func accelerate(magnitude):
	if (velocity + magnitude <= max_speed):
		velocity += magnitude

func decelerate(magnitude):
	if (velocity - magnitude >= min_speed):
		velocity -= magnitude
		
	
func _input(event):
	# On mouse button click
	if event is InputEventMouseButton:
		if drag:
			drag = false
		else:
			drag = true
