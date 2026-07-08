extends HBoxContainer

const CARD_UI_SCENE := preload("res://Scenes/ui/card_ui.tscn")

func mostrar_mano(cartas: Array[CardData]) -> void:
	for hijo in get_children():
		hijo.queue_free()

	for carta in cartas:
		var card_ui := CARD_UI_SCENE.instantiate()
		add_child(card_ui)
		card_ui.setear_carta(carta)
