class_name EnergyEffectData
extends EffectData

@export var cantidad: int = 1

func aplicar(fuente: CombatEntity, objetivo: CombatEntity) -> void: 
	if fuente is Player and fuente.energia_actual < fuente.energia_max: 
		print("energia actual: %d" % fuente.energia_actual)
		print("energia max: %d" % fuente.energia_max)
		fuente.sumar_energia(cantidad)
