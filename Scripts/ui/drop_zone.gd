extends Control

signal carta_soltada(carta: CardData, objetivo: CombatEntity)

@export var es_zona_propia: bool = false
@export var entidad: CombatEntity

func _can_drop_data(at_position: Vector2, data) -> bool: 
	if not (data is CardData):
		return false
	
	var carta: CardData = data
	match carta.tipo_objetivo:
		CardData.TipoObjetivo.PROPIO:
			return es_zona_propia
		CardData.TipoObjetivo.ENEMIGO_FIJO, CardData.TipoObjetivo.ENEMIGO_CUALQUIERA:
			return not es_zona_propia
		CardData.TipoObjetivo.LIBRE:
			return true
	return false
	
func _drop_data(at_position: Vector2, data) -> void: 
	var carta: CardData = data
	carta_soltada.emit(carta, entidad)
	
