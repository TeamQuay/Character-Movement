extends Sprite

onready var fire = $FireAnimator

func _ready():
	fire.play("FireAnimation")
