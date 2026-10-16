extends CharacterBody2D

var speed = 100.0
var last_direction = "down"

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(_delta):
	var input_direction = Input.get_vector("left", "righ", "up", "down")
	
	velocity = input_direction * speed
	
	if input_direction != Vector2.ZERO:
		if abs(input_direction.x) > abs(input_direction.y):
			if input_direction.x > 0:
				last_direction = "righ"
			else:
				last_direction = "left"
		else:
			if input_direction.y > 0:
				last_direction = "down"
			else: 
				last_direction = "up"
		
		animated_sprite.play("walk_" + last_direction)
	else:
		animated_sprite.play("idle_" + last_direction)
	
	move_and_slide()
