
extends Node2D
class_name EnemigoMundo

signal jugador_cerca(enemigo: EnemigoMundo)
signal jugador_lejos(enemigo: EnemigoMundo)
signal interaccion_solicitada(enemigo: EnemigoMundo)


enum EstadoMundo {
	IDLE,
	INTERACTUANDO,
	DERROTADO
}


var enemigo_id: String = ""
var enemy_data: EnemyData
var derrotado: bool = false
var jugador_en_rango: bool = false

var estado_actual: EstadoMundo = EstadoMundo.IDLE


@onready var area_interaccion: Area2D = $AreaInteraccion
@onready var area_clic: Area2D = $AreaClic
@onready var indicador_interaccion: Label = $IndicadorInteraccion
@onready var visual: AnimatedSprite2D = $Visual


func _ready() -> void:
	add_to_group("enemigos_mundo")

	area_interaccion.body_entered.connect(_on_body_entered)
	area_interaccion.body_exited.connect(_on_body_exited)
	area_clic.input_event.connect(_on_area_clic_input_event)

	visual.animation_finished.connect(_on_animation_finished)

	indicador_interaccion.hide()


func configurar(
	datos: EnemyData,
	id: String,
	esta_derrotado: bool = false
) -> void:
	if datos == null:
		push_error("EnemigoMundo: EnemyData no puede ser null.")
		return

	enemy_data = datos
	enemigo_id = id
	derrotado = esta_derrotado
	name = datos.nombre

	configurar_visual()


func configurar_visual() -> void:
	visual.stop()

	if enemy_data.sprite_frames_mundo == null:
		visual.sprite_frames = null
		push_warning(
			"EnemigoMundo: %s no tiene SpriteFrames de mundo." %
			enemy_data.nombre
		)
		return

	visual.sprite_frames = enemy_data.sprite_frames_mundo
	visual.scale = Vector2.ONE * enemy_data.escala_mundo

	if derrotado:
		mostrar_derrotado()
	else:
		reproducir_idle()


func reproducir_idle() -> void:
	estado_actual = EstadoMundo.IDLE

	if visual.sprite_frames.has_animation("mundo_idle"):
		visual.play("mundo_idle")
	else:
		push_warning(
			"EnemigoMundo: %s no tiene mundo_idle." %
			enemy_data.nombre
		)


func solicitar_interaccion() -> void:
	if derrotado:
		return

	if estado_actual != EstadoMundo.IDLE:
		return

	if not jugador_en_rango:
		return

	estado_actual = EstadoMundo.INTERACTUANDO
	indicador_interaccion.hide()

	if visual.sprite_frames == null:
		interaccion_solicitada.emit(self)
		return

	if not visual.sprite_frames.has_animation("mundo_interact"):
		push_warning(
			"EnemigoMundo: %s no tiene mundo_interact." %
			enemy_data.nombre
		)
		interaccion_solicitada.emit(self)
		return

	if visual.sprite_frames.get_animation_loop("mundo_interact"):
		push_warning(
			"EnemigoMundo: mundo_interact no debe tener loop."
		)
		interaccion_solicitada.emit(self)
		return

	visual.play("mundo_interact")


func mostrar_derrotado() -> void:
	derrotado = true
	estado_actual = EstadoMundo.DERROTADO

	deshabilitar_interaccion()

	if visual.sprite_frames == null:
		return

	if not visual.sprite_frames.has_animation("mundo_death"):
		push_warning(
			"EnemigoMundo: %s no tiene mundo_death." %
			enemy_data.nombre
		)
		return

	visual.play("mundo_death")


func mostrar_cadaver() -> void:
	derrotado = true
	estado_actual = EstadoMundo.DERROTADO

	deshabilitar_interaccion()

	if visual.sprite_frames == null:
		return

	if not visual.sprite_frames.has_animation("mundo_death"):
		return

	var total_frames := visual.sprite_frames.get_frame_count(
		"mundo_death"
	)

	if total_frames <= 0:
		return

	visual.stop()
	visual.animation = "mundo_death"
	visual.frame = total_frames - 1


func deshabilitar_interaccion() -> void:
	jugador_en_rango = false
	indicador_interaccion.hide()

	area_interaccion.set_deferred("monitoring", false)
	area_clic.set_deferred("input_pickable", false)


func _on_animation_finished() -> void:
	match estado_actual:
		EstadoMundo.INTERACTUANDO:
			interaccion_solicitada.emit(self)

		EstadoMundo.DERROTADO:
			mostrar_cadaver()


func _on_body_entered(body: Node2D) -> void:
	if derrotado:
		return

	if estado_actual != EstadoMundo.IDLE:
		return

	if body is CharacterBody2D:
		jugador_en_rango = true
		indicador_interaccion.show()
		jugador_cerca.emit(self)


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		jugador_en_rango = false
		indicador_interaccion.hide()
		jugador_lejos.emit(self)


func _on_area_clic_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			solicitar_interaccion()
