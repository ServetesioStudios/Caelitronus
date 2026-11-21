class_name EffectData
extends Resource

func aplicar(_fuente: CombatEntity, _objetivo: CombatEntity) -> void:
	pass

func ejecutar(
	_contexto: CardEffectContext,
	fuente: CombatEntity,
	objetivo: CombatEntity) -> void:
	
	aplicar(fuente, objetivo)

func puede_ejecutarse(_contexto: CardEffectContext) -> bool:
	return true
