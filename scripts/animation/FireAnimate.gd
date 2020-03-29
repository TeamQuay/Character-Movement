extends Sprite

onready var fire = $FireAnimator

func _ready():
	# play looped firepit flames animation
	fire.play("FireAnimation")
