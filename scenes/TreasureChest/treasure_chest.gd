extends StaticBody2D

var can_interact: bool = false
var is_open: bool = false
@export var chest_name: String

func _ready() -> void:
	if Manager.opened_chests.has(chest_name):
		is_open = true
		$AnimatedSprite2D.play("open")

func _process(delta: float) -> void:
	if !(Input.is_action_just_pressed("interact") and can_interact): return
	if is_open: return
		
	open()

func open() -> void:
	$AudioStreamPlayer2D.play()
	$AnimatedSprite2D.play("open")
	is_open = true
	$Reward.visible = true
	$Timer.start()
	Manager.opened_chests.append(chest_name)


func _on_timer_timeout() -> void:
	$Reward.visible = false
