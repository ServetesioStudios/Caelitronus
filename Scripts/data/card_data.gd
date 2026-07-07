class_name CardData
extends Resource

@export var card_name: String
@export_multiline var descripcion: String
@export var costo: int = 1
@export var arte: Texture2D
@export var efectos: Array[EffectData] = []

func jugar(fuente: CombatEntity, objetivo: CombatEntity) -> void:
	for efecto in efectos:
		efecto.aplicar(fuente, objetivo)
