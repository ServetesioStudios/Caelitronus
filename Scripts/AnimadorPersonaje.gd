class_name AnimadorPersonaje
extends Node

signal animacion_terminada(nombre:String)

@export var sprite: AnimatedSprite2D
@export var animacion_idle:= "idle"

func reproducir(nombre:String) -> void: 
	if sprite == null:
		push_warning("AnimadorPersonaje: 'sprite' no está asignado en el Inspector")
		return
	if sprite.sprite_frames == null:
		push_warning("AnimadorPersonaje: el sprite no tiene SpriteFrames asignado")
		return
	if not sprite.sprite_frames.has_animation(nombre):
		push_warning("Animación '%s' no encontrada" % nombre)
		return
	sprite.play(nombre)
	await sprite.animation_finished
	animacion_terminada.emit(nombre)
	if sprite.sprite_frames.has_animation(animacion_idle):
		sprite.play(animacion_idle)
