class_name AnimadorPersonaje
extends Node

signal animacion_terminada(nombre: String)

@export var sprite: AnimatedSprite2D

var animacion_idle: String = ""


func _ready() -> void:
	if sprite == null or sprite.sprite_frames == null:
		push_warning("AnimadorPersonaje: SpriteFrames no configurado.")
		return

	configurar_idle()
	reproducir_idle()


func configurar_idle() -> void:
	var frames := sprite.sprite_frames

	if frames.has_animation("idle"):
		animacion_idle = "idle"
		return

	if GameManager.player_data == null:
		push_warning("AnimadorPersonaje: no hay PlayerData para determinar el idle.")
		return

	match GameManager.player_data.tipo_caelius:
		GameManager.TipoCaelius.PENA:
			animacion_idle = "idle_pena"
		GameManager.TipoCaelius.IRA:
			animacion_idle = "idle_ira"
		GameManager.TipoCaelius.EGO:
			animacion_idle = "idle_ego"

	if not frames.has_animation(animacion_idle):
		push_warning("AnimadorPersonaje: no existe la animación %s." % animacion_idle)
		animacion_idle = ""


func reproducir_idle() -> void:
	if not is_instance_valid(sprite):
		return

	if sprite.sprite_frames == null or animacion_idle.is_empty():
		return

	if not sprite.sprite_frames.has_animation(animacion_idle):
		return

	sprite.play(animacion_idle)


func reproducir(nombre: String) -> void:
	if not is_instance_valid(sprite) or sprite.sprite_frames == null:
		push_warning("AnimadorPersonaje: sprite no configurado.")
		return

	if not sprite.sprite_frames.has_animation(nombre):
		push_warning("AnimadorPersonaje: animación '%s' no encontrada." % nombre)
		return

	sprite.play(nombre)

	if sprite.sprite_frames.get_animation_loop(nombre):
		push_warning("AnimadorPersonaje: la animación '%s' está configurada en bucle." % nombre)
		return

	await sprite.animation_finished

	if not is_instance_valid(sprite):
		return

	if sprite.animation != nombre:
		return

	animacion_terminada.emit(nombre)
	reproducir_idle()
