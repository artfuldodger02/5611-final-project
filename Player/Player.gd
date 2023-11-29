extends CharacterBody2D

var hp : float = 100
var speed : float = 250
var walking : bool = false

#attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")

#attack nodes
@onready var iceSpearTimer = get_node("Attack/IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("Attack/IceSpearTimer/IceSpearAttackTimer")

#ice spear details
var iceSpear_ammo = 0
var iceSpear_baseAmmo = 3
var iceSpear_attackSpeed: float = 1.5
var iceSpear_level = 1

#enemy details
var close_enemies = []



func _ready():
	$Sprite2D/PlayerAnimation.play("idle")
	attack()

func _physics_process(delta):
	
	velocity.x = 0
	velocity.y = 0
	
	if Input.is_key_pressed(KEY_LEFT) || Input.is_key_label_pressed(KEY_A):
		$Sprite2D.flip_h = true
		velocity.x -= 1
	
	if Input.is_key_pressed(KEY_RIGHT) || Input.is_key_label_pressed(KEY_D):
		$Sprite2D.flip_h = false
		velocity.x += 1
	
	if Input.is_key_pressed(KEY_UP) || Input.is_key_label_pressed(KEY_W):
		velocity.y -= 1
	
	if Input.is_key_pressed(KEY_DOWN) || Input.is_key_label_pressed(KEY_S):
		velocity.y += 1
		
	if (velocity.x != 0 && velocity.y != 0):
		velocity.x *= 0.75
		velocity.y *= 0.75
		
	if (velocity.x != 0 || velocity.y != 0):
		walking = true
	else:
		walking = false
		
	velocity *= speed
	
	move_and_slide()

func _process(delta):
	if walking:
		$Sprite2D/PlayerAnimation.play("walk_right")
	else:
		$Sprite2D/PlayerAnimation.play("idle")
		
func _on_hurt_box_hurt(damage):
	hp -= damage
	print(hp)
	
func attack():
	if iceSpear_level > 0:
		iceSpearTimer.wait_time = iceSpear_attackSpeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
			


func _on_ice_spear_timer_timeout():
	iceSpear_ammo += iceSpear_baseAmmo
	iceSpearAttackTimer.start()


func _on_ice_spear_attack_timer_timeout():
	if iceSpear_ammo > 0:
		var iceSpear_attack = iceSpear.instantiate()
		iceSpear_attack.position = position
		iceSpear_attack.target = get_random_target()
		iceSpear_attack.level = iceSpear_level
		add_child(iceSpear_attack)
		iceSpear_ammo -= 1
		if iceSpear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()
		
func get_random_target():
	if close_enemies.size() > 0:
		return close_enemies.pick_random().global_position
	else: 
		return Vector2.UP
		


func _on_enemy_detection_area_body_entered(body):
	if not close_enemies.has(body):
		close_enemies.append(body)
		


func _on_enemy_detection_area_body_exited(body):
	if close_enemies.has(body):
		close_enemies.erase(body)
