class_name ConditionalDamageEffectData
extends EffectData

@export_group("Daño")
@export var dano_base: int = 6
@export var dano_adicional : int = 3

@export_group("Condición")
@export_range(0.0, 1.0, 0.01)
var umbral_vida: float = 0.5

@export var ignora_bloqueo: bool = false

func aplicar(
	fuente: CombatEntity,
	objetivo: CombatEntity
) -> void:

	if fuente == null or objetivo == null:
		return

	var dano_total: int = dano_base

	# Comprobar porcentaje de vida del Caelius.
	if fuente.max_hp > 0:
		var porcentaje_vida: float = (
			float(fuente.hp) / float(fuente.max_hp)
		)

		if porcentaje_vida < umbral_vida:
			dano_total += dano_adicional

	# Aplicar el daño usando el sistema existente.
	objetivo.recibir_daño(
		dano_total,
		ignora_bloqueo
	)
