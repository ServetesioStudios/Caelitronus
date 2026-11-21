class_name HealEffectData
extends EffectData

@export_group("Curación")
@export var cantidad: int = 4

@export_group("Curación condicional")
@export var curacion_condicional: bool = false
@export_range(0.0, 1.0, 0.05) var umbral_vida: float = 0.5
@export var curacion_adicional: int = 4


func aplicar(fuente: CombatEntity, objetivo: CombatEntity) -> void:
	if fuente == null or fuente.max_hp <= 0:
		return

	var curacion_total: int = cantidad

	# Comprobar la condición antes de curar.
	if curacion_condicional:
		var porcentaje_vida: float = float(fuente.hp) / float(fuente.max_hp)

		if porcentaje_vida < umbral_vida:
			curacion_total += curacion_adicional

	# Aplicar la curación sin superar la vida máxima.
	fuente.hp = mini(
		fuente.hp + curacion_total,
		fuente.max_hp
	)

	fuente.actualizar_barra_vida()
