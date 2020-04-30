extends KinematicBody2D

signal update_health(current_health)
signal death()

# vars for movement properties
var max_speed = 150			# Max speed the player can move (orig. 700)
var movement = Vector2.ZERO # Stores movement in R^2 vector
var move_click = false		# Whether player clicked to move

# vars for movement latency and more
var latency_frames = 11		# Number of frames of latency to apply to movement
var latency_list = []		# List used to "count down" frames before movement
var max_health = 100

# vars created when _ready called ("$" is a way to get node in the same scene)
onready var animate_movement = $movement_animator
onready var animate_tree = $animation_tree
# gets access the the root from animation tree
onready var animate_state = animate_tree.get("parameters/playback")
onready var animate_damage = $damage_animator
onready var current_health = max_health setget set_health
onready var damage_interval_timer = $damage_int_timer
onready var joystick = $HUD/joystick/joystick_button


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Spawned: Player with ", current_health, "hp.")


# Runs every frame
func _process(_delta):
	movement = joystick.get_value()
	var direction_vector = movement.normalized()
	
	# animations when player is moving
	if (movement != Vector2.ZERO):
		animate_tree.set("parameters/idle_animations/blend_position", direction_vector)
		animate_tree.set("parameters/walk_animations/blend_position", direction_vector)
		animate_state.travel("walk_animations")
	# when player halts
	else:
		animate_state.travel("idle_animations")
		
	movement = move_and_slide(movement * max_speed)


func _input(event):
	# FOR TESTING: player takes damage when "A" key pressed
	if (event is InputEventKey):
		if (event.pressed  and event.scancode == KEY_A):
			damage_player(10)

# health and damage functions below ---------------------------

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
	
