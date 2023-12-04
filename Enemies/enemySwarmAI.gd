extends CharacterBody2D

@export var movement_speed = 1.0
var max_speed = 2.0
@export var hp : float = 5
@export var knockback_recovery = 3.5
var knockback = Vector2.ZERO


@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var sound_hit = $sound_hit
var death_anim = preload("res://Enemies/explosion.tscn")

# swarming variables
var is_swarm = true
var swarm_members = []
var seperation_distance = 30
var acceleration = Vector2()
var direction = Vector2(0, 1)



signal remove_from_array(object)

func _ready():
	randomize()
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() 

func _physics_process(delta):
	
	if(direction.x < 0):
		$Sprite2D.flip_h = true
		rotation = Vector2(0,1).angle_to(direction)-deg_to_rad(90)
	else:
		rotation = Vector2(0,1).angle_to(direction)+deg_to_rad(90)
		$Sprite2D.flip_h = false
	acceleration = Vector2(0,0)
	var prey_direction: Vector2 = global_position.direction_to(player.global_position)
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	
	if(global_position.distance_to(player.global_position) > 1000):
		direction = flock_direction() + (prey_direction )
	else:
		direction = flock_direction() + (prey_direction * 0.01 * (1000 / global_position.distance_to(player.global_position)))
	
	velocity = direction * movement_speed
	velocity.limit_length(movement_speed) * delta
	velocity += knockback
	move_and_slide()
	
# START SWARMING FUNCTIONS
func flock_direction():
	var seperation = Vector2()
	var heading = direction
	var cohesion = Vector2()
	
	for boid in swarm_members:
		if boid == self:
			return direction
		else:
			heading += boid.direction
			cohesion += boid.global_position
			var distance = global_position.distance_to(boid.global_position)
			
			if distance < seperation_distance:
				seperation -= (boid.global_position - global_position).normalized() * (seperation_distance / distance * movement_speed)
		if(swarm_members.size() > 0):
			heading = heading / swarm_members.size()
			cohesion = cohesion / swarm_members.size()
			
			var center_direction = global_position.direction_to(cohesion)
			var center_speed = max_speed * global_position.direction_to(cohesion) / $detection_rad/CollisionShape2D.shape.radius
			cohesion = center_direction * center_speed
	
	return (direction + (seperation * 0.5) + (heading * 0.5) + (cohesion * 0.1)).limit_length(max_speed)
	

	
# END SWARMING FUNCTIONS

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
	if body.is_swarm && (body != self): 
		
		swarm_members.append(body)


func _on_detection_rad_body_exited(body):
	if swarm_members.has(body): 
		
		swarm_members.erase(body)
		
		
