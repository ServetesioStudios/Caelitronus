class_name DeckManager
extends Node

signal mano_actualizada(mano: Array[CardData])
signal cartas_robadas(cartas: Array[CardData])

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

func descartar_carta(
	indice: int,
	carta: CardData
) -> bool:

	if not es_carta_en_indice(indice, carta):
		push_warning(
			"DeckManager: índice de descarte inválido."
		)
		return false

	var carta_descartada: CardData = mano[indice]

	mano.remove_at(indice)
	mazo_descarte.append(carta_descartada)

	mano_actualizada.emit(mano)

	return true
	
		
func jugar_carta(
	indice: int,
	carta: CardData) -> bool:

	return descartar_carta(indice, carta)


func robar_cartas(cantidad: int) -> void: 
	_robar(cantidad)


func _robar(cantidad: int) -> void:
	var nuevas_cartas: Array[CardData] = []

	for i in range(cantidad):
		if mazo_robo.is_empty():
			_reciclar_descarte()

			if mazo_robo.is_empty():
				break

		var carta_robada: CardData = mazo_robo.pop_back()

		if mano.size() < TAMANO_MANO:
			mano.append(carta_robada)
			nuevas_cartas.append(carta_robada)
		else:
			mazo_descarte.append(carta_robada)

	if not nuevas_cartas.is_empty():
		cartas_robadas.emit(nuevas_cartas)

	mano_actualizada.emit(mano)
	

func _descartar_mano() -> void:
	mazo_descarte.append_array(mano)
	mano.clear()

func _reciclar_descarte() -> void:
	mazo_robo = mazo_descarte.duplicate()
	mazo_robo.shuffle()
	mazo_descarte.clear()
	
	
func es_carta_en_indice(
	indice: int,
	carta: CardData
) -> bool:

	if indice < 0 or indice >= mano.size():
		return false

	if carta == null:
		return false

	return mano[indice] == carta
