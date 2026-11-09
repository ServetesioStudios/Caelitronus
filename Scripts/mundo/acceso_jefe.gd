extends Area2D

@export var zona_id: String = "zona_roja"

@onready var indicador: Polygon2D = $Polygon2D

var desbloqueado: bool = false


func _ready() -> void:
	actualizar_estado()


func actualizar_estado() -> void:
	desbloqueado = GameManager.estado_expedicion.todos_enemigos_derrotados(zona_id)

	if desbloqueado:
		indicador.color = Color.GREEN
		print("AccesoJefe: acceso desbloqueado en ", zona_id)
	else:
		indicador.color = Color.RED
		print("AccesoJefe: acceso bloqueado en ", zona_id)
