extends StaticBody2D

signal switch_activated
signal switch_deactivated

var can_interact: bool = false
var is_activated: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact:
		$AudioStreamPlayer2D.play()
		if is_activated:
			activate()
		else:
			deactivate()

func activate() -> void:
	$AnimatedSprite2D.play("deactivated")
	is_activated = false
	switch_deactivated.emit()
	
func deactivate() -> void:
	$AnimatedSprite2D.play("activated")
	is_activated = true
	switch_activated.emit()
