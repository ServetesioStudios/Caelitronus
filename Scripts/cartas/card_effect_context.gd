class_name CardEffectContext
extends RefCounted

var deck_manager: DeckManager
var mano_ui: Control

var cancelado: bool = false

func _init(p_deck_manager: DeckManager) -> void:
	deck_manager = p_deck_manager


# ============================================================
# CONFIGURACIÓN
# ============================================================

func configurar_mano(p_mano_ui: Control) -> void:
	mano_ui = p_mano_ui


# ============================================================
# CONSULTAS
# ============================================================

func cantidad_cartas_en_mano() -> int:
	return deck_manager.mano.size()


# ============================================================
# ACCIONES SOBRE EL MAZO
# ============================================================

func robar_cartas(cantidad: int) -> void:
	deck_manager.robar_cartas(cantidad)


func descartar_carta(card_ui: CardUI) -> bool:
	if cancelado:
		return false

	if not is_instance_valid(mano_ui):
		cancelado = true
		return false

	if not is_instance_valid(card_ui):
		cancelado = true
		return false

	var indice: int = mano_ui.obtener_indice_carta(card_ui)

	if not deck_manager.descartar_carta(indice, card_ui.carta):
		cancelado = true
		return false

	return true

# ============================================================
# SELECCIÓN INTERACTIVA
# ============================================================


func solicitar_descarte() -> CardUI:
	if cancelado:
		return null

	if not is_instance_valid(mano_ui):
		push_error(
			"CardEffectContext: no hay una mano configurada."
		)
		cancelado = true
		return null

	if deck_manager.mano.is_empty():
		cancelado = true
		return null

	mano_ui.iniciar_seleccion_descarte()

	var card_ui: CardUI = await mano_ui.seleccion_descarte_resuelta

	if cancelado:
		return null

	if not is_instance_valid(mano_ui):
		cancelado = true
		return null

	mano_ui.finalizar_seleccion_descarte()

	if not is_instance_valid(card_ui):
		cancelado = true
		return null

	var indice: int = mano_ui.obtener_indice_carta(card_ui)

	if not deck_manager.es_carta_en_indice(indice, card_ui.carta):
		cancelado = true
		return null

	return card_ui
	

func cancelar_ejecucion() -> void:
	cancelado = true

	if is_instance_valid(mano_ui):
		mano_ui.cancelar_seleccion_descarte()
