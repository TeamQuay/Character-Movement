extends Area2D

var thorn_damage = 5

func _on_ThornBush_dmg_body_entered(body):
	if (body.get_name() == "player"):
		body.damage_player(thorn_damage)
