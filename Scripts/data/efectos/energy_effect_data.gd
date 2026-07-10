class_name EnergyEffectData
extends EffectData

@export var cantidad: int = 1

func aplicar(fuente: CombatEntity, objetivo: CombatEntity) -> void: 
	if fuente is Player: 
		fuente.sumar_energia(cantidad)
