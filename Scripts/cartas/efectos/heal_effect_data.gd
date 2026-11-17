class_name HealEffectData
extends EffectData

@export var cantidad: int = 4

func aplicar(fuente: CombatEntity, objetivo: CombatEntity) -> void:
	fuente.hp = min(fuente.hp + cantidad, fuente.max_hp)
	fuente.actualizar_barra_vida()
