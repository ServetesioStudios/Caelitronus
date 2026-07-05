class_name EnemyData
extends Resource

enum Religion {
	NINGUNA,
	SAGRADA,
	OSCURA,
}

@export var nombre: String
@export var religion: Religion = Religion.NINGUNA
@export var stats: Stats
@export var sprite: Texture2D
