extends CharacterBody2D

var hp = 100
var maxhp = 100 
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

#upgrades
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var aug_speed = 0
var cooldown = 0
var spell_size = 0
var additional_attacks = 0

#ice spear details
var iceSpear_ammo = 0
var iceSpear_baseAmmo = 0
var iceSpear_attackSpeed: float = 1.5
var iceSpear_level = 0

#whirlwind details
var whirlwind_ammo = 0
var whirlwind_baseAmmo = 0
var whirlwind_attackSpeed: float = 3.0
var whirlwind_level = 0

#lance details
var lance_ammo = 0
var lance_level = 0

#enemy details
var close_enemies = []
var is_swarm = false

#GUI details
@onready var xp_bar = get_node("%XpBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgrades = get_node("%Upgrades")
@onready var soundLevelUp = get_node("%sound_levelup")
@onready var itemOptions = preload("res://Utility/item_option.tscn")

func _ready():
	# upgrade_char("iceSpear1")
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
	hp -= clamp(damage-armor, 1.0, 999.0)
	print(hp)
	
func attack():
	if iceSpear_level > 0:
		iceSpearTimer.wait_time = iceSpear_attackSpeed * (1 - cooldown)
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
			
	if whirlwind_level > 0:
		whirlwindTimer.wait_time = whirlwind_attackSpeed * (1 - cooldown)
		if whirlwindTimer.is_stopped():
			whirlwindTimer.start()
	if lance_level > 0:
		spawn_lance()
			


func _on_ice_spear_timer_timeout():
	iceSpear_ammo += iceSpear_baseAmmo + additional_attacks
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
	whirlwind_ammo += whirlwind_baseAmmo + additional_attacks
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
	var calcSpawns = (lance_ammo + additional_attacks) - get_total
	
	while calcSpawns > 0:
		var lance_spawn = lance.instantiate()
		lance_spawn.global_position = global_position
		lanceBase.add_child(lance_spawn)
		calcSpawns -= 1
	
	# update lance
	var get_lances = lanceBase.get_children()
	for i in get_lances:
		if i.has_method("update_lance"):
			i.update_lance()
		
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
		levelup()
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
	
func levelup():
	soundLevelUp.play()
	lblLevel.text = str("Level: ", xp_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(360,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var options_max = 3
	while options < options_max:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_rand_item()
		upgrades.add_child(option_choice)
		options += 1
	get_tree().paused = true

func upgrade_char(upgrade):
	match upgrade:
		"iceSpear1":
			iceSpear_level = 1
			iceSpear_baseAmmo += 1
		"iceSpear2":
			iceSpear_level = 2
			iceSpear_baseAmmo += 1
		"iceSpear3":
			iceSpear_level = 3
		"iceSpear4":
			iceSpear_level = 4
			iceSpear_baseAmmo += 2
		"whirlwind1":
			whirlwind_level = 1
			whirlwind_baseAmmo += 1
		"whirlwind2":
			whirlwind_level = 2
			whirlwind_baseAmmo += 1
		"whirlwind3":
			whirlwind_level = 3
			whirlwind_attackSpeed -= 0.5
		"whirlwind4":
			whirlwind_level = 4
			whirlwind_baseAmmo += 1
		"dragonlance1":
			lance_level = 1
			lance_ammo = 1
		"dragonlance2":
			lance_level = 2
		"dragonlance3":
			lance_level = 3
		"dragonlance4":
			lance_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			speed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp)

	
	attack()
	
	var option_children = upgrades.get_children()
	for child in option_children:
		child.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(400,-500)
	get_tree().paused = false
	calculate_xp(0)
	
	
func get_rand_item():
	var dbList = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: #determine which upgrades have already been collected
			pass
		elif i in upgrade_options: #if its already an option
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item": #dont pick food, leave it as default when we run out of options
			pass
		elif UpgradeDb.UPGRADES[i]["prereq"].size() > 0: # check for prereqs
			for n in UpgradeDb.UPGRADES[i]["prereq"]:
				if not n in collected_upgrades: #dont pick items with prereqs we dont fulfil
					pass
				else:
					dbList.append(i)
		else:
			dbList.append(i)
	if dbList.size() > 0:
		var randomitem = dbList.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null
