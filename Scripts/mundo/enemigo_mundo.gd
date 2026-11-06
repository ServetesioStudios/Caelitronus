extends Node2D
class_name EnemigoMundo

signal jugador_cerca(enemigo: EnemigoMundo)
signal jugador_lejos(enemigo: EnemigoMundo)

var enemigo_id: String = ""
var enemy_data: EnemyData
var derrotado: bool = false

@onready var area_interaccion: Area2D = $AreaInteraccion
@onready var indicador_interaccion: Label = $IndicadorInteraccion


func _ready() -> void:
	area_interaccion.body_entered.connect(_on_body_entered)
	area_interaccion.body_exited.connect(_on_body_exited)

func configurar(datos: EnemyData, id: String, esta_derrotado: bool = false) -> void:
	enemy_data = datos
	enemigo_id = id
	derrotado = esta_derrotado
	name = datos.nombre

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		indicador_interaccion.show()
		jugador_cerca.emit(self)
		print("Jugador cerca de: %s" % enemy_data.nombre)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		indicador_interaccion.hide()
		jugador_lejos.emit(self)
		print("Jugador se alejó de: %s" % enemy_data.nombre)
