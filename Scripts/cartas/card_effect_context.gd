class_name CardEffectContext
extends RefCounted

var deck_manager: DeckManager


func _init(p_deck_manager: DeckManager) -> void:
	deck_manager = p_deck_manager


func cantidad_cartas_en_mano() -> int:
	return deck_manager.mano.size()


func robar_cartas(cantidad: int) -> void:
	deck_manager.robar_cartas(cantidad)


func descartar_carta(carta: CardData) -> void:
	deck_manager.descartar_carta(carta)
