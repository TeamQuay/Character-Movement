extends Control

onready var health_bar = $HealthProgress

func _on_Player_update_health(current_health):
	health_bar.value = current_health
