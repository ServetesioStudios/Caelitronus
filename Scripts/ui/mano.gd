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

	var carta: CardData = card_ui.carta

	var energia_insuficiente: bool = not player_ref.puede_pagar(carta.costo)

	var es_carta_energia: bool = (
		carta.efectos.size() == 1
		and carta.efectos[0] is EnergyEffectData
	)

	var energia_completa: bool = player_ref.energia_actual >= player_ref.energia_max

	var carta_bloqueada: bool = energia_insuficiente or (
		es_carta_energia and energia_completa
	)

	if carta_bloqueada:
		card_ui.modulate = Color(0.5, 0.5, 0.5, 0.6)
	else:
		card_ui.modulate = Color(1, 1, 1, 1)
