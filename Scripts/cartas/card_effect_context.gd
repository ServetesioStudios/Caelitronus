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


func descartar_carta(carta: CardData) -> void:
	deck_manager.descartar_carta(carta)


# ============================================================
# SELECCIÓN INTERACTIVA
# ============================================================


func solicitar_descarte() -> CardData:
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

	var carta: CardData = await mano_ui.seleccion_descarte_resuelta

	# La ejecución pudo cancelarse mientras esperábamos.
	if cancelado:
		return null

	# La interfaz pudo desaparecer.
	if not is_instance_valid(mano_ui):
		cancelado = true
		return null

	mano_ui.finalizar_seleccion_descarte()

	if carta == null or not carta in deck_manager.mano:
		cancelado = true
		return null

	return carta


func cancelar_ejecucion() -> void:
	cancelado = true

	if is_instance_valid(mano_ui):
		mano_ui.cancelar_seleccion_descarte()
