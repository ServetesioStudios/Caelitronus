extends HBoxContainer

const CARD_UI_SCENE := preload("res://Scenes/ui/card_ui.tscn")

var player_ref: Player

func mostrar_mano(cartas: Array[CardData]) -> void:
	for hijo in get_children():
		hijo.queue_free()
	for carta in cartas:
		var card_ui := CARD_UI_SCENE.instantiate()
		add_child(card_ui)
		card_ui.setear_carta(carta)
		_actualizar_disponibilidad(card_ui)

func actualizar_disponibilidad_todas() -> void:
	for card_ui in get_children():
		if card_ui is CardUI:
			_actualizar_disponibilidad(card_ui)

func _actualizar_disponibilidad(card_ui: CardUI) -> void:
	if card_ui.carta == null:
		print("Carta nula encontrada en:", card_ui.name)
		return
		
	if player_ref.puede_pagar(card_ui.carta.costo):
		card_ui.modulate = Color(1, 1, 1, 1)
	else:
		card_ui.modulate = Color(0.5, 0.5, 0.5, 0.6)
