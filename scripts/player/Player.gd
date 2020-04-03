# inherits from KinematicBody2D
extends KinematicBody2D

signal update_health(current_health)
signal death()

# vars for movement properties
var accel = 20 				# How fast the player accelerates (orig. 15)
var decel = 25				# How fast the player decelerates (orig. 30)
var max_speed = 500			# Max speed the player can move (orig. 700)
var min_speed = 0			# Minimum speed the player can move
var velocity = 0			# Current velocity
var movement = Vector2.ZERO # Stores movement in R^2 vector
var move_click = false		# Whether player clicked to move

# vars for movement latency and more
var latency_frames = 11		# Number of frames of latency to apply to movement
var latency_list = []		# List used to "count down" frames before movement
var max_health = 100

# vars created when _ready called ("$" is a way to get node in the same scene)
onready var animate_movement = $MovementAnimator
onready var animate_damage = $DamageAnimator
onready var current_health = max_health setget set_health
onready var damage_interval_timer = $DamageIntervalTimer
onready var joystick = $HUD/Joystick/JoystickButton


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Spawned: Player with ", current_health, "hp.")
	for _i in range(latency_frames):
		latency_list.append(Vector2.ZERO)

# movement functions --------------------------------------

# Runs every frame
func _process(_delta):
	movement = joystick.get_value()
	
	# animations
	if (movement != Vector2.ZERO):
		if (movement.x > 0):
			animate_movement.play("WalkRight")
		else:
			animate_movement.play("WalkLeft")
	else:
		animate_movement.play("IdleLeft")

	#movement = apply_latency(movement)
	movement = move_and_slide(movement * max_speed)


func accelerate(magnitude):
	if (velocity + magnitude <= max_speed):
		velocity += magnitude

func decelerate(magnitude):
	if (velocity - magnitude >= min_speed):
		velocity -= magnitude

func apply_latency(vector):
	latency_list.append(vector)
	if (len(latency_list) > latency_frames):
		latency_list.remove(0)
	return latency_list[0]
	
func _input(event):
	# FOR TESTING: player takes damage when "A" key pressed
	if (event is InputEventKey):
		if (event.pressed  and event.scancode == KEY_A):
			damage_player(10)

# ---------------------------------------------------------

func kill_player():
	# WIP
	print("Player dead! .. or is he?")
	pass
	
func damage_player(val):
	# good idea here to reduce damage based on resistances
	# don't damage if within free interval
	if (damage_interval_timer.is_stopped()):
		damage_interval_timer.start()
		# call set_health with new hp after damaged
		set_health(current_health - val)
		# play red flicker damage animation
		animate_damage.play("DamageRedFlicker")
		
func _on_DamageIntervalTimer_timeout():
	# when not taking damage, reset to "idle" no-flicker state
	animate_damage.play("NoDamage")


func set_health(val):
	var old_health = current_health
	current_health = clamp(val, 0, max_health)
	# if health changed, send update signal
	if (current_health != old_health):
		emit_signal("update_health", current_health)
		# if health 0, kill player
		if (current_health == 0):
			kill_player()
			emit_signal("death")
	# FOR TESTING: print health to console
	print("Health:", current_health)
	
