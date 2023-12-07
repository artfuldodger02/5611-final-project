extends CharacterBody2D

@export var movement_speed = 20.0
@export var hp : float = 10
@export var knockback_recovery = 3.5
@export var xp = 1
@export var enemy_damage = 1
var knockback = Vector2.ZERO


@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var sound_hit = $sound_hit
@onready var sound_combine = $sound_combine
@onready var combine_area = get_node("%Combine_area")
@onready var hitbox = get_node("HitBox")

var death_anim = preload("res://Enemies/explosion.tscn")
var xp_gem = preload("res://Objects/exp.tscn")
var is_swarm = false
var is_slime = true

var slimelist = []
var maxslimes = 5


signal remove_from_array(object)

func _ready():
	hitbox.damage = enemy_damage

func _physics_process(delta):
	# only combine with slimes that have less than or equal to hp than self
	for s in slimelist:
		if s.hp > self.hp:
			slimelist.erase(s)
	
	if slimelist.size() >= maxslimes:
		var removed_slimes = 0
		for i in slimelist:
			if removed_slimes <= maxslimes:
				self.scale = self.scale + (i.scale / 2)
				self.hp = self.hp + (i.hp / 2)
				self.movement_speed = self.movement_speed + (i.movement_speed / 5)
				self.xp = self.xp + i.xp
				hitbox.damage = hitbox.damage + 3
				
				slimelist.erase(i)
				i.queue_free()
				removed_slimes += 1
				combine_area.scale = combine_area.scale * (1/1.25)
		self.scale.clamp(Vector2(1.0,1.0), Vector2(4.0,4.0))
		maxslimes = maxslimes * 2
		sound_combine.play()
	
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()

func death():
	emit_signal("remove_from_array", self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var new_gem = xp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.xp = xp
	loot_base.call_deferred("add_child", new_gem)
	queue_free()
	

func _on_hurt_box_hurt(damage, angle, knockback_strength):
	hp -= damage
	knockback = angle * knockback_strength
	if hp <= 0:
		death()
	else:
		sound_hit.play()





func _on_combine_area_body_entered(body):
	if body.is_slime && body != self:
		slimelist.append(body)


func _on_combine_area_body_exited(body):
	if slimelist.has(body):
		slimelist.erase(body)
