
class_name EnemyData
extends Resource

enum Religion { NINGUNA, SAGRADA, OSCURA }

@export_group("Identificación")
@export var id: StringName
@export var nombre: String
@export var religion: Religion = Religion.NINGUNA

@export_group("Combate")
@export var stats: Stats
@export var escena_combate: PackedScene
