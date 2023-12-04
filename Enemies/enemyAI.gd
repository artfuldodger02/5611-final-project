extends CharacterBody2D

@export var movement_speed = 20.0
@export var hp : float = 10
@export var knockback_recovery = 3.5
var knockback = Vector2.ZERO


@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var sound_hit = $sound_hit

var death_anim = preload("res://Enemies/explosion.tscn")
var is_swarm = false


signal remove_from_array(object)


func _physics_process(delta):
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
	queue_free()
	

func _on_hurt_box_hurt(damage, angle, knockback_strength):
	hp -= damage
	knockback = angle * knockback_strength
	if hp <= 0:
		death()
	else:
		sound_hit.play()



func _on_detection_rad_body_entered(body):
	pass # Replace with function body.
