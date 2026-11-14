class_name ConditionalBlockEffectData
extends EffectData

@export_group("Escudo")
@export var cantidad: int = 8
@export var bonus_sin_daño: int = 3


func aplicar(fuente: CombatEntity, objetivo: CombatEntity) -> void:
	if not is_instance_valid(fuente):
		return

	fuente.bloqueo += cantidad
	fuente.bonus_escudo_pendiente += bonus_sin_daño

	fuente.actualizar_escudo()
