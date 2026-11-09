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

@export_group("Representación en el mundo")
@export var sprite_frames_mundo: SpriteFrames
@export_range(0.05, 2.0, 0.05) var escala_mundo: float = 1.0
