extends CharacterBody2D

var hp : float = 100
var speed : float = 250
var walking : bool = false
var last_movement = Vector2.UP

# xp variables
var xp = 0
var xp_level = 1
var collected_xp = 0

#attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var whirlwind = preload("res://Player/Attack/whirlwind.tscn")
var lance = preload("res://Player/Attack/lance.tscn")


#attack nodes
@onready var iceSpearTimer = get_node("Attack/IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("Attack/IceSpearTimer/IceSpearAttackTimer")

@onready var whirlwindTimer = get_node("Attack/WhirlwindTimer")
@onready var whirlwindAttackTimer = get_node("Attack/WhirlwindTimer/WhirlwindAttackTimer")

@onready var lanceBase = get_node("%LanceBase")

#ice spear details
var iceSpear_ammo = 0
var iceSpear_baseAmmo = 1
var iceSpear_attackSpeed: float = 1.5
var iceSpear_level = 0


#whirlwind details
var whirlwind_ammo = 0
var whirlwind_baseAmmo = 1
var whirlwind_attackSpeed: float = 3.0
var whirlwind_level = 0

#lance details
var lance_ammo = 1
var lance_level = 1

#enemy details
var close_enemies = []
var is_swarm = false

#GUI details
@onready var xp_bar = get_node("%XpBar")
@onready var lblLevel = get_node("%lbl_level")

func _ready():
	$Sprite2D/PlayerAnimation.play("idle")
	attack()
	set_xp_bar(xp, calculate_xp_cap())

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
		last_movement = Vector2(velocity.x, velocity.y)
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
		
func _on_hurt_box_hurt(damage, _angle, _knockback_strength):
	hp -= damage
	print(hp)
	
func attack():
	if iceSpear_level > 0:
		iceSpearTimer.wait_time = iceSpear_attackSpeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
			
	if whirlwind_level > 0:
		whirlwindTimer.wait_time = whirlwind_attackSpeed
		if whirlwindTimer.is_stopped():
			whirlwindTimer.start()
	if lance_level > 0:
		spawn_lance()
			


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
			
func _on_whirlwind_timer_timeout():
	whirlwind_ammo += whirlwind_baseAmmo
	whirlwindAttackTimer.start()


func _on_whirlwind_attack_timer_timeout():
	if whirlwind_ammo > 0:
		var whirlwind_attack = whirlwind.instantiate()
		whirlwind_attack.position = position
		whirlwind_attack.last_movement = last_movement
		whirlwind_attack.level = whirlwind_level
		add_child(whirlwind_attack)
		whirlwind_ammo -= 1
		if whirlwind_ammo > 0:
			whirlwindAttackTimer.start()
		else:
			whirlwindAttackTimer.stop()
		
		
func spawn_lance():
	var get_total = lanceBase.get_child_count()
	var calcSpawns = lance_ammo - get_total
	
	while calcSpawns > 0:
		var lance_spawn = lance.instantiate()
		lance_spawn.global_position = global_position
		lanceBase.add_child(lance_spawn)
		calcSpawns -= 1
		
		
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



func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_xp = area.collect()
		calculate_xp(gem_xp)
		
func calculate_xp(gem_xp):
	var xp_req = calculate_xp_cap()
	collected_xp += gem_xp
	if xp + collected_xp >= xp_req: #leveling up
		collected_xp -= (xp_req-xp) #xp carries over
		xp_level += 1
		lblLevel.text = str("Level: ", xp_level)
		xp = 0
		xp_req = calculate_xp_cap()
		calculate_xp(0) #recalculate to avoid errors
	else:
		xp += collected_xp
		collected_xp = 0 
	set_xp_bar(xp, xp_req)
	
func calculate_xp_cap():
	var xp_cap = xp_level
	if xp_level < 20:
		xp_cap = xp_level * 5
	elif xp_level < 40:
		xp_cap = 95 * (xp_level - 19) * 8
	else:
		xp_cap = 255 + (xp_level - 39) * 12
	return xp_cap
	
func set_xp_bar(set_val = 1, set_max_val = 100):
	xp_bar.value = set_val
	xp_bar.max_value = set_max_val
