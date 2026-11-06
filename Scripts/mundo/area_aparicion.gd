@tool
extends Area2D
class_name AreaAparicion

@export_group("Identificación")
@export var area_id: String = ""
@export var habilitada: bool = true

@export_group("Enemigos")
@export var enemigos: Array[ConfiguracionEnemigo] = []

@export_group("Reglas de aparición")
@export_range(0.0, 500.0, 1.0) var separacion_minima: float = 32.0
