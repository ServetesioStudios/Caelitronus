
extends CharacterBody2D

signal invocacion_terminada

@export_group("Sprites de Caelius")
@export var sprites_ira: SpriteFrames
@export var sprites_pena: SpriteFrames
@export var sprites_ego: SpriteFrames

var speed := 100.0
var last_direction: String = "down"

var invocando: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	configurar_apariencia()
	animated_sprite.animation_finished.connect(_on_animation_finished)


func configurar_apariencia() -> void:
	if GameManager.player_data == null:
		push_error("MiniPlayer: PlayerData es nulo.")
		return

	var sprites_seleccionados: SpriteFrames = null

	match GameManager.player_data.tipo_caelius:
		GameManager.TipoCaelius.PENA:
			sprites_seleccionados = sprites_pena

		GameManager.TipoCaelius.IRA:
			sprites_seleccionados = sprites_ira

		GameManager.TipoCaelius.EGO:
			sprites_seleccionados = sprites_ego

	if sprites_seleccionados == null:
		push_error(
			"MiniPlayer: no hay SpriteFrames asignados para el Caelius tipo %s."
			% GameManager.player_data.tipo_caelius
		)
		return

	animated_sprite.sprite_frames = sprites_seleccionados
	animated_sprite.play("idle_down")
	

func _physics_process(_delta: float) -> void:
	# Impedir el movimiento durante la invocación.
	if invocando:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_direction := Input.get_vector(
		"left",
		"right",
		"up",
		"down"
	)

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


func iniciar_invocacion(enemigo: EnemigoMundo) -> void:
	if invocando or enemigo == null:
		return

	invocando = true
	velocity = Vector2.ZERO

	var direccion := enemigo.global_position - global_position

	if abs(direccion.x) > abs(direccion.y):
		if direccion.x > 0:
			last_direction = "right"
		else:
			last_direction = "left"
	else:
		if direccion.y > 0:
			last_direction = "down"
		else:
			last_direction = "up"

	var nombre_animacion := "invo_" + last_direction

	if animated_sprite.sprite_frames == null:
		finalizar_invocacion()
		return

	if not animated_sprite.sprite_frames.has_animation(nombre_animacion):
		push_warning("No existe la animación: %s" % nombre_animacion)
		finalizar_invocacion()
		return

	animated_sprite.play(nombre_animacion)


func _on_animation_finished() -> void:
	if not invocando:
		return

	if animated_sprite.animation.begins_with("invo_"):
		finalizar_invocacion()


func finalizar_invocacion() -> void:
	if not invocando:
		return

	invocando = false
	animated_sprite.play("idle_" + last_direction)
	invocacion_terminada.emit()


func _unhandled_key_input(event: InputEvent) -> void:
	if invocando:
		return

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
