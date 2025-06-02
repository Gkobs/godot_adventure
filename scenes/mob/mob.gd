extends CharacterBody2D

var target: Node2D
@export var speed: float = 30
@export var accelaration: float = 5
@export var hp: int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if hp <= 0: return
	
	chase_target()
	animate()
	move_and_slide()
	
	
func animate() -> void:
	var normal_velocity: Vector2 = velocity.normalized()
	
	if normal_velocity.x > 0.707:
		$AnimatedSprite2D.play("move_right")
	if normal_velocity.y > 0.707:
		$AnimatedSprite2D.play("move_down")
	if normal_velocity.x < -0.707:
		$AnimatedSprite2D.play("move_left")
	if normal_velocity.y < -0.707:
		$AnimatedSprite2D.play("move_up")

func chase_target() -> void:
	if !target: return
	
	var distance_to_target = target.global_position - global_position
	var normal_velocity = distance_to_target.normalized()
	velocity = velocity.move_toward(normal_velocity * speed, accelaration)

func _on_aggro_area_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body
		
func play_damage_sfx() -> void:
	$DamageSFX.play()
	
func take_damage() -> void:
	hp -= 1
	
	if is_instance_valid(self):
		play_damage_sfx()
	
	var flash_red: Color = Color(50, 0.5, 0.5)
	modulate = flash_red
		
	await get_tree().create_timer(0.2).timeout
	if is_instance_valid(self):
		var original_color: Color = Color(1, 1, 1)
		modulate = original_color
	
	if hp <= 0:
		die()
		
func die() -> void:
	$GPUParticles2D.emitting = true
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	await get_tree().create_timer(1).timeout
	
	queue_free()
	
	
