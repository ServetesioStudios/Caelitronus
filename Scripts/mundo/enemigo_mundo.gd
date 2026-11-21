extends Node2D
class_name EnemigoMundo

signal jugador_cerca(enemigo: EnemigoMundo)
signal jugador_lejos(enemigo: EnemigoMundo)
signal interaccion_solicitada(enemigo: EnemigoMundo)
signal interaccion_iniciada(enemigo: EnemigoMundo)

enum EstadoMundo {
	IDLE,
	INTERACTUANDO,
	DERROTADO
}

var enemigo_id: String = ""
var enemy_data: EnemyData
var derrotado: bool = false
var jugador_en_rango: bool = false
var jugador: CharacterBody2D = null

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

	visual.animation_finished.connect(_on_animacion_terminada)


func _process(_delta: float) -> void:
	if estado_actual == EstadoMundo.IDLE and jugador_en_rango:
		mirar_hacia_jugador()
		

func configurar(
	datos: EnemyData,
	id: String,
	esta_derrotado: bool = false) -> void:
	if datos == null:
		push_error("EnemigoMundo: EnemyData es nulo.")
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
		push_warning("Enemigo sin SpriteFrames de mundo: %s" % enemy_data.nombre)
		return

	visual.sprite_frames = enemy_data.sprite_frames_mundo
	visual.scale = Vector2.ONE * enemy_data.escala_mundo

	if derrotado:
		mostrar_cadaver()
		return

	reproducir_idle()


func reproducir_idle() -> void:
	if derrotado:
		return

	estado_actual = EstadoMundo.IDLE

	if visual.sprite_frames != null:
		if visual.sprite_frames.has_animation("mundo_idle"):
			visual.play("mundo_idle")


func _on_body_entered(body: Node2D) -> void:
	if derrotado or estado_actual != EstadoMundo.IDLE:
		return

	if body is CharacterBody2D:
		jugador = body
		jugador_en_rango = true
		indicador_interaccion.show()

		mirar_hacia_jugador()

		jugador_cerca.emit(self)


func _on_body_exited(body: Node2D) -> void:
	if body == jugador:
		jugador_en_rango = false
		jugador = null

		indicador_interaccion.hide()
		jugador_lejos.emit(self)


func _on_area_clic_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if jugador_en_rango:
				solicitar_interaccion()


func solicitar_interaccion() -> void:
	if derrotado or estado_actual != EstadoMundo.IDLE:
		return

	if not jugador_en_rango:
		return

	estado_actual = EstadoMundo.INTERACTUANDO
	indicador_interaccion.hide()

	interaccion_iniciada.emit(self)

	if visual.sprite_frames == null:
		_finalizar_interaccion()
		return

	if not visual.sprite_frames.has_animation("mundo_interact"):
		_finalizar_interaccion()
		return

	visual.play("mundo_interact")


func _on_animacion_terminada() -> void:
	if estado_actual == EstadoMundo.INTERACTUANDO:
		if visual.animation == "mundo_interact":
			_finalizar_interaccion()

	elif estado_actual == EstadoMundo.DERROTADO:
		if visual.animation == "mundo_death":
			mostrar_cadaver()
			

func _finalizar_interaccion() -> void:
	if estado_actual != EstadoMundo.INTERACTUANDO:
		return
	interaccion_solicitada.emit(self)


func mirar_hacia_jugador() -> void:
	if not is_instance_valid(jugador):
		return

	var diferencia_x: float = jugador.global_position.x - global_position.x

	if abs(diferencia_x) < 4.0:
		return

	visual.flip_h = diferencia_x > 0
	

func reproducir_muerte() -> void:
	derrotado = true
	estado_actual = EstadoMundo.DERROTADO
	jugador_en_rango = false
	indicador_interaccion.hide()

	if visual.sprite_frames == null:
		return

	if not visual.sprite_frames.has_animation("mundo_death"):
		push_warning("No existe mundo_death en: %s" % enemy_data.nombre)
		return

	visual.play("mundo_death")
	visual.set_frame_and_progress(0, 0.0)


func mostrar_cadaver() -> void:
	derrotado = true
	estado_actual = EstadoMundo.DERROTADO
	jugador_en_rango = false
	indicador_interaccion.hide()

	if visual.sprite_frames == null:
		return

	if not visual.sprite_frames.has_animation("mundo_death"):
		return

	visual.play("mundo_death")
	visual.stop()

	var cantidad_frames: int = visual.sprite_frames.get_frame_count("mundo_death")

	if cantidad_frames > 0:
		visual.frame = cantidad_frames - 1
