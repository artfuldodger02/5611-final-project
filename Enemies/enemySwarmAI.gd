extends CharacterBody2D

@export var movement_speed = 40.0
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
var acceleration = Vector2()
var steer_force = 1.0
var alignment_force = 1.2
var cohesion_force = 1.0
var seperation_force = 1.0
var avoidance_force = 1.0
var centralization_force = 1.0
var pursuit_force = 4.0
var perception_radius = 15
#var prey_position: Vector2 = player.global_position


signal remove_from_array(object)

func _ready():
	randomize()
	velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * movement_speed

func _physics_process(delta):
	acceleration = Vector2(0,0)
	var prey_direction: Vector2 = global_position.direction_to(player.global_position)
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	
	acceleration += process_alignments() * alignment_force
	acceleration += process_cohesion() * cohesion_force
	#acceleration += process_seperation() 
	acceleration += prey_direction * pursuit_force
	
	velocity += acceleration * delta
	velocity = velocity.normalized() * movement_speed
	print(velocity)
	velocity += knockback
	move_and_slide()
	
# START SWARMING FUNCTIONS
	
func process_cohesion():
	var vector = Vector2()
	var member_num = 0
	if swarm_members.is_empty():
		return vector
	for boid in swarm_members:
		vector += boid.position
		member_num += 1
	vector = vector / member_num
	
	return steer((vector - position).normalized() * movement_speed)
	
func process_alignments():
	var vector = Vector2()
	var member_num = 0
	if swarm_members.is_empty():
		return vector
		
	for boid in swarm_members:
		vector += boid.velocity
		member_num += 1
	vector = vector / member_num
	
	return steer(vector.normalized() * movement_speed)
	
	
func process_seperation():
	var seperation = Vector2()
	var member_num = 0
	var close_members = []
	for boid in swarm_members:
		if position.distance_to(boid.position) < perception_radius / 2:
			close_members.push_back(boid)
	if close_members.is_empty():
		return seperation
	
	for boid in close_members:
		var difference = position - boid.position
		seperation += difference.normalized() / difference.length()
		member_num += 1
	
	seperation = seperation / member_num
	
	return steer(seperation.normalized() * movement_speed)
	

func steer(target):
	var steer = target - velocity
	steer = steer.normalized() * steer_force
	
	return steer
	
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
	if body.is_swarm: 
		#print("added to swarm")
		swarm_members.append(body)


func _on_detection_rad_body_exited(body):
	if swarm_members.has(body): 
		#print("remove from swarm")
		swarm_members.erase(body)
		
		
