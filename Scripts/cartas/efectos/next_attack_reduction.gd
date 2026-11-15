class_name NextAttackReductionEffectData
extends EffectData

@export_group("Protección")
@export var cantidad_escudo: int = 15
@export var reduccion_ataque: int = 3


func aplicar(fuente: CombatEntity, objetivo: CombatEntity) -> void:
	if not is_instance_valid(fuente):
		return

	# Otorgar escudo inmediatamente.
	fuente.bloqueo += cantidad_escudo

	# Activar protección para el próximo ataque.
	fuente.reduccion_proximo_ataque = reduccion_ataque

	fuente.actualizar_escudo()
