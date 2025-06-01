extends StaticBody2D

var can_interact: bool = false
@export var lines: Array[String] = ["Hello there!", "I'm Mariana  I'm here to guide you", "You can talk to Monkey or Tengu, they know where you should go next"]
var lines_index: int = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact:
		$AudioStreamPlayer2D.play()
		if lines_index < lines.size():
			$CanvasLayer.visible = true
			get_tree().paused = true
			$CanvasLayer/DialogLabel.text = lines[lines_index]
			lines_index += 1
		else:
			$CanvasLayer.visible = false
			get_tree().paused = false
			lines_index = 0
