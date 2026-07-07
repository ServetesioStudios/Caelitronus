class_name BlockEffectData
extends EffectData

@export var cantidad: int = 1

func aplicar(fuente: CombatEntity, objetivo: CombatEntity) -> void:
	objetivo.bloqueo += cantidad
