extends Control

onready var health_bar = $health_progress

# visually updates health bar when update_health called
func _on_Player_update_health(current_health):
	health_bar.value = current_health
