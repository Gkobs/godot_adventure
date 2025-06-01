extends CharacterBody2D
class_name Player

@export var move_speed: float = 100
@export var push_strenght: float = 300

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_treasure_label()
	if Manager.player_spawn_position != Vector2(0, 0):
		position = Manager.player_spawn_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_player()
	push_object()
	move_and_slide()
	update_treasure_label()
	update_hp_bar()
	
	if Input.is_action_just_pressed("interact"):
		attack()
	
	
func update_treasure_label() -> void:
	%TreasureLabel.text = str(Manager.opened_chests.size())
	
func move_player() -> void:
	var move_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_vector * move_speed
	
	var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
	var interact_area: Area2D = $Area2D
	if velocity.y > 0:
		animated_sprite.play('move_down')
		interact_area.position = Vector2(0, 8)
	elif velocity.y < 0:
		animated_sprite.play('move_up')
		interact_area.position = Vector2(0, -8)
	elif velocity.x < 0:
		animated_sprite.play('move_left')
		interact_area.position = Vector2(-8, 0)
	elif velocity.x > 0:
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
		body.can_interact = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		body.can_interact = false


func _on_hit_box_body_entered(body: Node2D) -> void:
	Manager.player_hp -= 1
	update_hp_bar()
	if Manager.player_hp == 0:
		die()
	
	
func die() -> void:
	Manager.player_hp = 3
	get_tree().call_deferred("reload_current_scene")
	
func update_hp_bar() -> void:
	var animation: String = "%shp"
	%HpBar.play(animation % Manager.player_hp)

func attack() -> void:
	$Sword.visible = true
	%SwordArea2D.monitoring = true
	$AttackDurationTimer.start()

func _on_sward_area_2d_body_entered(body: Node2D) -> void:
	body.queue_free()


func _on_attack_duration_timer_timeout() -> void:
	$Sword.visible = false
	%SwordArea2D.monitoring = false
