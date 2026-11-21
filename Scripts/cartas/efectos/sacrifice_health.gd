class_name SacrificeHealthEffectData
extends EffectData

@export_range(1, 10, 1) var cantidad: int = 4


func aplicar(
	fuente: CombatEntity,
	_objetivo: CombatEntity
) -> void:
	if fuente == null:
		return

	fuente.sacrificar_vida(cantidad)
