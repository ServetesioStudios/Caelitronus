extends CharacterBody2D

@export_group("Sprites de Caelius")
@export var sprites_ira: SpriteFrames
@export var sprites_pena: SpriteFrames
@export var sprites_ego: SpriteFrames

var speed := 100.0
var last_direction = "down"

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	configurar_apariencia()

func configurar_apariencia() -> void:
	var sprites_seleccionados: SpriteFrames 

	match GameManager.player_data.tipo_caelius:
		GameManager.TipoCaelius.PENA:
			if sprites_pena != null:
				sprites_seleccionados = sprites_pena

		GameManager.TipoCaelius.IRA:
			sprites_seleccionados = sprites_ira

		GameManager.TipoCaelius.EGO:
			if sprites_ego != null:
				sprites_seleccionados = sprites_ego

	if sprites_seleccionados != null:
		animated_sprite.sprite_frames = sprites_seleccionados
		

func _physics_process(_delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = input_direction * speed
	
	if input_direction != Vector2.ZERO:
		if abs(input_direction.x) > abs(input_direction.y):
			if input_direction.x > 0:
				last_direction = "right"
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



func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interactuar"):
		return

	if not event is InputEventKey:
		return

	var enemigo_cercano: EnemigoMundo = null
	var distancia_minima: float = INF

	for enemigo in get_tree().get_nodes_in_group("enemigos_mundo"):
		if not enemigo is EnemigoMundo:
			continue

		if not enemigo.jugador_en_rango:
			continue

		var distancia := global_position.distance_to(enemigo.global_position)

		if distancia < distancia_minima:
			distancia_minima = distancia
			enemigo_cercano = enemigo

	if enemigo_cercano != null:
		enemigo_cercano.solicitar_interaccion()
