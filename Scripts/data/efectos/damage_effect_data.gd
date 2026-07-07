class_name DamageEffectData
extends EffectData

@export var cantidad: int = 1

func aplicar(fuente: CombatEntity, objetivo: CombatEntity) -> void:
	objetivo.recibir_daño(cantidad)
