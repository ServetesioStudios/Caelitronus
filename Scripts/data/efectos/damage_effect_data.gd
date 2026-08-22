class_name DamageEffectData
extends EffectData

@export var cantidad: int = 1
@export var ignora_bloqueo: bool = false

func aplicar(fuente: CombatEntity, objetivo: CombatEntity) -> void:
	objetivo.recibir_daño(cantidad, ignora_bloqueo)
