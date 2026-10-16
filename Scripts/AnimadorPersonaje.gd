class_name AnimadorPersonaje
extends Node

signal animacion_terminada(nombre:String)

var tipo_caelius : GameManager.TipoCaelius
@export var sprite: AnimatedSprite2D
var animacion_idle= ""

func _ready():
	tipo_caelius = GameManager.player_data.tipo_caelius
	
	match tipo_caelius:
		GameManager.TipoCaelius.PENA: animacion_idle = "idle_pena"
		GameManager.TipoCaelius.IRA: animacion_idle = "idle_ira"
		GameManager.TipoCaelius.EGO: animacion_idle = "idle_ego"
		_:
			push_warning("AnimadorPersonaje: tipo de Caelius desconocido")
			return
	
	reproducir_idle()

func reproducir_idle() -> void:
	if sprite == null:
		push_warning("AnimadorPersonaje: sprite no asignado")
		return

	if sprite.sprite_frames == null:
		push_warning("AnimadorPersonaje: SpriteFrames no asignado")
		return 
		
	if not sprite.sprite_frames.has_animation(animacion_idle):
		push_warning("No existe la animación: " + animacion_idle)
		return

	sprite.play(animacion_idle)
	
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
	reproducir_idle()
