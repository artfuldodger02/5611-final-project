extends CharacterBody2D

var speed : float = 250
var walking : bool = false

func _ready():
	$Sprite2D/PlayerAnimation.play("idle")

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
