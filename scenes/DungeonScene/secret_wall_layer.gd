extends TileMapLayer

func disable() -> void:
	visible = false
	collision_enabled = false
	
func enable() -> void:
	visible = true
	collision_enabled = true


func _on_switch_switch_activated() -> void:
	disable()


func _on_switch_switch_deactivated() -> void:
	enable()
