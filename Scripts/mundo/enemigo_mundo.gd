extends Node2D
class_name EnemigoMundo

signal jugador_cerca(enemigo: EnemigoMundo)
signal jugador_lejos(enemigo: EnemigoMundo)
signal interaccion_solicitada(enemigo: EnemigoMundo)


var enemigo_id: String = ""
var enemy_data: EnemyData
var derrotado: bool = false
var jugador_en_rango: bool = false


@onready var area_interaccion: Area2D = $AreaInteraccion
@onready var area_clic: Area2D = $AreaClic
@onready var indicador_interaccion: Label = $IndicadorInteraccion


func _ready() -> void:
	add_to_group("enemigos_mundo")
	area_interaccion.body_entered.connect(_on_body_entered)
	area_interaccion.body_exited.connect(_on_body_exited)
	area_clic.input_event.connect(_on_area_clic_input_event)
	


func configurar(datos: EnemyData, id: String, esta_derrotado: bool = false) -> void:
	enemy_data = datos
	enemigo_id = id
	derrotado = esta_derrotado
	name = datos.nombre

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		jugador_en_rango = true
		indicador_interaccion.show()
		jugador_cerca.emit(self)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		jugador_en_rango = false
		indicador_interaccion.hide()
		jugador_lejos.emit(self)
			
func _on_area_clic_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if jugador_en_rango:
				solicitar_interaccion()
				
func solicitar_interaccion() -> void:
	print("Interacción solicitada con: %s (%s)" % [
		enemy_data.nombre,
		enemigo_id
	])
	interaccion_solicitada.emit(self)			
