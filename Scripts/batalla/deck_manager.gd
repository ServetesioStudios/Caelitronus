class_name DeckManager
extends Node

signal mano_actualizada(mano: Array[CardData])

const TAMANO_MANO := 5

var mazo_robo: Array[CardData] = []
var mazo_descarte: Array[CardData] = []
var mano: Array[CardData] = []

func iniciar_mazo(deck_original: Array[CardData]) -> void:
	mazo_robo = deck_original.duplicate()
	mazo_robo.shuffle()
	mazo_descarte.clear()
	mano.clear()

func iniciar_turno() -> void:
	_descartar_mano()
	_robar(TAMANO_MANO)

func jugar_carta(carta: CardData) -> void:
	if carta in mano:
		mano.erase(carta)
		mazo_descarte.append(carta)
		mano_actualizada.emit(mano)

func _robar(cantidad: int) -> void:
	for i in cantidad:
		if mazo_robo.is_empty():
			_reciclar_descarte()
			if mazo_robo.is_empty():
				break 
		mano.append(mazo_robo.pop_back())
	mano_actualizada.emit(mano)

func _descartar_mano() -> void:
	mazo_descarte.append_array(mano)
	mano.clear()

func _reciclar_descarte() -> void:
	mazo_robo = mazo_descarte.duplicate()
	mazo_robo.shuffle()
	mazo_descarte.clear()
