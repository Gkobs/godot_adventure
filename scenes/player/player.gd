extends CharacterBody2D
class_name Player

@export var move_speed: float = 100
@export var push_strenght: float = 300
@export var acceleration: float = 5
var is_attacking: bool = false
var can_interact: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_treasure_label()
	if Manager.player_spawn_position != Vector2(0, 0):
		position = Manager.player_spawn_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Manager.player_hp <= 0: return
	
	if not is_attacking:
		move_player()
	push_object()
	move_and_slide()
	update_treasure_label()
	update_hp_bar()
	
	if Input.is_action_just_pressed("interact") and !can_interact:
		attack()
	
	
func update_treasure_label() -> void:
	%TreasureLabel.text = str(Manager.opened_chests.size())
	
func move_player() -> void:
	var move_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.move_toward(move_vector * move_speed, acceleration)
	
	var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
	var interact_area: Area2D = $Area2D
	var normalized_velocity = velocity.normalized()
	if normalized_velocity.y > 0.707:
		animated_sprite.play('move_down')
		interact_area.position = Vector2(0, 8)
	elif normalized_velocity.y < -0.707:
		animated_sprite.play('move_up')
		interact_area.position = Vector2(0, -8)
	elif normalized_velocity.x < -0.707:
		animated_sprite.play('move_left')
		interact_area.position = Vector2(-8, 0)
	elif normalized_velocity.x > 0.707:
		animated_sprite.play('move_right')
		interact_area.position = Vector2(8, 0)
	else:
		animated_sprite.stop()
	
func push_object() -> void:
	var collision: KinematicCollision2D = get_last_slide_collision()
	if collision:
		var collider_node = collision.get_collider()
		
		if collider_node.is_in_group("pushable"):
			var collision_normal: Vector2 = collision.get_normal()
			collider_node.apply_central_force(-(collision_normal * push_strenght))


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		can_interact = true
		body.can_interact = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		can_interact = false
		body.can_interact = false


func _on_hit_box_body_entered(body: Node2D) -> void:
	Manager.player_hp -= 1
	update_hp_bar()
	if Manager.player_hp == 0: die()
		
	var distance_to_player: Vector2 = global_position - body.global_position
	var normal_velocity: Vector2 = distance_to_player.normalized()
	velocity += normal_velocity * 200
	
	$DamageSFX.play()
	
	var flash_white: Color = Color(50, 50, 50)
	modulate = flash_white
	
	await get_tree().create_timer(0.2).timeout
	
	var original_color: Color = Color(1, 1, 1)
	modulate = original_color

func die() -> void:
	if !$OnDeathTimer.is_stopped(): return
	
	$OnDeathTimer.start()
	$AnimatedSprite2D.play("death")

func update_hp_bar() -> void:
	var animation: String = "%shp"
	%HpBar.play(animation % Manager.player_hp)

func attack() -> void:
	if !$AttackDurationTimer.is_stopped(): return
	
	$SwingSwordSFX.play()
	
	velocity = Vector2(0, 0)
	is_attacking = true
	$Sword.visible = true
	%SwordArea2D.monitoring = true
	$AttackDurationTimer.start()
	
	var player_animation: String = $AnimatedSprite2D.animation
	if player_animation == "move_right":
		$AnimatedSprite2D.play("attack_right")
		$AnimationPlayer.play("attack_right")
	elif player_animation == "move_left":
		$AnimatedSprite2D.play("attack_left")
		$AnimationPlayer.play("attack_left")
	elif player_animation == "move_up":
		$AnimatedSprite2D.play("attack_up")
		$AnimationPlayer.play("attack_up")
	elif player_animation == "move_down":
		$AnimatedSprite2D.play("attack_down")
		$AnimationPlayer.play("attack_down")

func _on_sward_area_2d_body_entered(body: Node2D) -> void:
	var distance_to_enemy: Vector2 = body.global_position - global_position
	var knockback_direction: Vector2 = distance_to_enemy.normalized()
	var knockback_strength: int = 150
	body.velocity += knockback_direction * knockback_strength
	
	body.take_damage()


func _on_attack_duration_timer_timeout() -> void:
	$Sword.visible = false
	%SwordArea2D.monitoring = false
	is_attacking = false
	
	var player_animation: String = $AnimatedSprite2D.animation
	if player_animation == "attack_right":
		$AnimatedSprite2D.play("move_right")
	elif player_animation == "attack_left":
		$AnimatedSprite2D.play("move_left")
	elif player_animation == "attack_up":
		$AnimatedSprite2D.play("move_up")
	elif player_animation == "attack_down":
		$AnimatedSprite2D.play("move_down")


func _on_on_death_timer_timeout() -> void:
	Manager.player_hp = 3
	get_tree().call_deferred("reload_current_scene")
