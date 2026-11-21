class_name UIMazos
extends Control

@onready var label_mazo_robo: Label = $MazoRobo/LabelCantidad
@onready var label_mazo_descarte: Label = $MazoDescarte/LabelCantidad

var deck_manager: DeckManager


# ============================================================
# CONFIGURACIÓN
# ============================================================

func configurar(nuevo_deck_manager: DeckManager) -> void:
	if nuevo_deck_manager == null:
		push_error("UIMazos: falta DeckManager.")
		return

	if deck_manager != null:
		if deck_manager.mano_actualizada.is_connected(
			_on_mano_actualizada
		):
			deck_manager.mano_actualizada.disconnect(
				_on_mano_actualizada
			)

	deck_manager = nuevo_deck_manager

	deck_manager.mano_actualizada.connect(
		_on_mano_actualizada
	)

	actualizar_contadores()


# ============================================================
# ACTUALIZACIÓN VISUAL
# ============================================================

func _on_mano_actualizada(_cartas: Array[CardData]) -> void:
	actualizar_contadores()


func actualizar_contadores() -> void:
	if not is_instance_valid(deck_manager):
		return

	label_mazo_robo.text = str(
		deck_manager.mazo_robo.size()
	)

	label_mazo_descarte.text = str(
		deck_manager.mazo_descarte.size()
	)
