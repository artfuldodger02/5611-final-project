extends Area2D


@export var xp = 1

var spr_blue = preload("res://Sprites/gems_db16/sprite_2.png")
var spr_red = preload("res://Sprites/gems_db16/sprite_4.png")
var spr_white = preload("res://Sprites/gems_db16/sprite_5.png")

var target = null
var speed = -0.75

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $sound_collect

func _ready():
	if xp < 5:
		return
	elif xp < 25:
		sprite.texture = spr_red
	else:
		sprite.texture = spr_white
		
func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2*delta
		
func collect():
		sound.play()
		collision.call_deferred("set","disable", true)
		sprite.visible = false
		return xp
		


func _on_sound_collect_finished():
	queue_free()
