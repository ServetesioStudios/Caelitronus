extends Control
signal carta_soltada(carta: CardData, posicion_global: Vector2)

func _can_drop_data(at_position: Vector2, data) -> bool:
	return data is CardData

func _drop_data(at_position: Vector2, data) -> void:
	carta_soltada.emit(data, get_global_mouse_position())
