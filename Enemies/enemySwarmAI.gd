extends CharacterBody2D

@export var movement_speed = 1.0
var max_speed = 2.0
@export var hp : float = 5
@export var knockback_recovery = 3.5
@export var xp = 2
@export var enemy_damage = 1
var knockback = Vector2.ZERO
var is_slime = false


@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var sound_hit = $sound_hit
var death_anim = preload("res://Enemies/explosion.tscn")
var xp_gem = preload("res://Objects/exp.tscn")

# swarming variables
var is_swarm = true
var swarm_members = []
var seperation_distance = 30
var acceleration = Vector2()
var direction = Vector2(0, 1)



signal remove_from_array(object)

func _ready():
	# randomize the starting directions of all swarmers
	randomize()
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() 
	

func _physics_process(delta):
	# flip the sprite towards the direction the swarmer is moving
	# and change the angle to face the directoin is moving
	if(direction.x < 0):
		$Sprite2D.flip_h = true
		rotation = Vector2(0,1).angle_to(direction)-deg_to_rad(90)
	else:
		rotation = Vector2(0,1).angle_to(direction)+deg_to_rad(90)
		$Sprite2D.flip_h = false
	# set direction to player
	var prey_direction: Vector2 = global_position.direction_to(player.global_position)
	# set knockback for weapons
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	
	# lasso force: if swarmer moves too far from player, start moving towards them agressively
	if(global_position.distance_to(player.global_position) > 1000):
		direction = flock_direction() + (prey_direction)
	else:
		# the closer the swarmer is the the player within 1000 units, the stronger the swarmer moves towards the player
		direction = flock_direction() + (prey_direction * 0.01 * (1000 / global_position.distance_to(player.global_position)))
		
	#add forces to velocity, restrict to speed of movement, account for knockback when relevent
	velocity = direction * movement_speed
	velocity.limit_length(movement_speed) * delta
	velocity += knockback
	move_and_slide()
	
# START SWARMING FUNCTIONS - Based off Vinicius Gerevini's implementation https://github.com/viniciusgerevini/godot-boids
func flock_direction():
	# set seperation, heading, and cohesion variables
	var seperation = Vector2()
	var heading = direction
	var cohesion = Vector2()
	
	# parse through all swarm members
	for boid in swarm_members:
		# if we somehow get ourselves inside the list, just return regular direction
		if boid == self:
			return direction
		else:
			# do alignment
			heading += boid.direction
			# do cohesion
			cohesion += boid.global_position
			# find distance from self to other swarmer
			var distance = global_position.distance_to(boid.global_position)
			# keep swarmers from getting too close to eachother aka seperation
			if distance < seperation_distance:
				seperation -= (boid.global_position - global_position).normalized() * (seperation_distance / distance * movement_speed)
		# if there is a swarm
		if(swarm_members.size() > 0):
			# reduce the strength of the alignment and cohesion forces by the size of the swarm
			heading = heading / swarm_members.size()
			cohesion = cohesion / swarm_members.size()
			
			#find where the center is and how fast we should go towards it
			var center_direction = global_position.direction_to(cohesion)
			var center_speed = max_speed * global_position.direction_to(cohesion) / $detection_rad/CollisionShape2D.shape.radius
			cohesion = center_direction * center_speed
			
	# return the sum of the seperation, heading, and cohesion forces with some fiddling to make the process feel better
	return (direction + (seperation * 0.5) + (heading * 0.5) + (cohesion * 0.1)).limit_length(max_speed)
	

	
# END SWARMING FUNCTIONS

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

# if another swarmer enters the detection radius, add it to the swarm
func _on_detection_rad_body_entered(body):
	# make sure we dont add ourselves to the list of other swarmers
	if body.is_swarm && (body != self): 
		swarm_members.append(body)

# if a swarmer leaves the detection radius, remove it from the list
func _on_detection_rad_body_exited(body):
	if swarm_members.has(body): 
		swarm_members.erase(body)
		
		
