extends Area2D

var level = 1
var hp = 999
var speed = 200.0
var damage = 10
var attack_size = 1.0
var knockback_strength = 100

var paths = 1
var attack_speed = 4.0
var target = Vector2.ZERO
var target_array = []

var angle = Vector2.ZERO
var reset_pos = Vector2.ZERO

var spr_lance_reg = preload("res://Sprites/DragonLances/sprite_2.png")
var spr_lance_attack = preload("res://Sprites/DragonLances/sprite_1.png")

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var attackTimer = get_node("%AttackTimer")
@onready var changeDirectionTimer = get_node("%ChangeDirectionTimer")
@onready var resetPosTimer = get_node("%ResetPosTimer")
@onready var sound_play = $sound_play

signal remove_from_array(object)

func _ready():
	update_lance()
	_on_reset_pos_timer_timeout()

func update_lance():
	level = player.lance_level
	match level:
		1:
			hp = 999
			speed = 200.0
			damage = 10
			knockback_strength = 100
			paths = 1
			attack_size = 2.5 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.cooldown)
		2:
			hp = 999
			speed = 300.0
			damage = 10
			knockback_strength = 100
			paths = 2
			attack_size = 2.5 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.cooldown)
		3:
			hp = 999
			speed = 300.0
			damage = 10
			knockback_strength = 100
			paths = 3
			attack_size = 2.5 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.cooldown)
		4:
			hp = 999
			speed = 300.0
			damage = 15
			knockback_strength = 120
			paths = 3
			attack_size = 2.5 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.cooldown)
			
	scale = Vector2(0.2,0.2) * attack_size
	attackTimer.wait_time = attack_speed
	
func _physics_process(delta):
	if target_array.size() > 0:
		position += angle * speed * delta
	else:
		var player_angle = global_position.direction_to(reset_pos)
		var distance_dif = global_position - player.global_position
		var return_speed = 20
		if abs(distance_dif.y) > 500 or abs(distance_dif.x) > 500:
			return_speed = 100
		position += player_angle * return_speed * delta
		rotation = global_position.direction_to(player.global_position).angle() - deg_to_rad(90)

func add_paths():
	sound_play.play()
	emit_signal("remove_from_array",self)
	target_array.clear()
	var counter = 0
	while counter < paths:
		var new_path = player.get_random_target()
		target_array.append(new_path)
		counter += 1
		enable_attack(true)
	target = target_array[0]
	process_path()
	
func process_path():
	angle = global_position.direction_to(target)
	changeDirectionTimer.start()
	var tween = create_tween()
	var new_rot_deg = angle.angle() + deg_to_rad(90)
	tween.tween_property(self,"rotation",new_rot_deg,0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func enable_attack(attack = true):
	if attack:
		collision.call_deferred("set","disabled",false)
		sprite.texture = spr_lance_attack
	else:
		collision.call_deferred("set","disabled",true)
		sprite.texture = spr_lance_reg

func _on_attack_timer_timeout():
	add_paths()

func _on_change_direction_timer_timeout():
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			sound_play.play()
			emit_signal("remove_from_array", self)
		else:
			enable_attack(false)
	else:
		changeDirectionTimer.stop()
		attackTimer.start()
		enable_attack(false)


func _on_reset_pos_timer_timeout():
	var choose_dir = randi() % 4
	reset_pos = player.global_position
	match choose_dir:
		0:
			reset_pos.x += 50
		1:
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50
