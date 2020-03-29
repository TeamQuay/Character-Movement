# inherits from KinematicBody2D
extends KinematicBody2D

# signals
signal update_health(current_health)
signal death()

# vars for movement properties
var accel = 20 				# How fast the player accelerates (orig. 15)
var decel = 25				# How fast the player decelerates (orig. 30)
var max_speed = 700			# Max speed the player can move
var min_speed = 0			# Minimum speed the player can move

# vars for runtime
var velocity = 0
var movement = Vector2.ZERO
var drag = false
var max_health = 100

# vars created when _ready called ("$" is a way to get node in the same scene)
onready var animate_movement = $MovementAnimator
onready var animate_damage = $DamageAnimator
onready var current_health = max_health setget set_health
onready var damage_interval_timer = $DamageIntervalTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Spawned: Player with ", current_health, "hp.")


# Runs every frame
func _physics_process(_delta):
	# get mouse pos and set next movement
	var pos = get_global_mouse_position()
	movement = pos - position
	
	# if click and movement non-zero, accelerate
	if (drag and movement != Vector2.ZERO):
		# play walkright if movement is positive x, else walkleft
		if movement.x > 0:
			animate_movement.play("WalkRight")
		else:
			animate_movement.play("WalkLeft")
		accelerate(accel)
	else:
		animate_movement.play("IdleLeft")
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

# movement functions --------------------------------------

func accelerate(magnitude):
	if (velocity + magnitude <= max_speed):
		velocity += magnitude

func decelerate(magnitude):
	if (velocity - magnitude >= min_speed):
		velocity -= magnitude
		
	
func _input(event):
	# On mouse button click
	if (event is InputEventMouseButton):
		if drag:
			drag = false
		else:
			drag = true
	# FOR TESTING: player takes damage when "A" key pressed
	elif (event is InputEventKey):
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
		# call set_health with new val
		set_health(current_health - val)
		# play red flicker damage animation
		animate_damage.play("DamageRedFlicker")
		
func _on_DamageIntervalTimer_timeout():
	# when timer timeouts, reset to "idle" no-flicker state
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
