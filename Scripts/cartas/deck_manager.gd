class_name DeckManager
extends Node

signal mano_actualizada(mano: Array[CardData])
signal cartas_robadas(cartas: Array[CardData])
signal estado_robo_actualizado(robando: bool)

const TAMANO_MANO := 5

var mazo_robo: Array[CardData] = []
var mazo_descarte: Array[CardData] = []
var mano: Array[CardData] = []

var robando: bool = false
var robo_cancelado: bool = false

var presentar_robo: Callable
var presentar_reciclaje: Callable


# ============================================================
# INICIALIZACIÓN
# ============================================================

func iniciar_mazo(deck_original: Array[CardData]) -> void:
	mazo_robo = deck_original.duplicate()
	mazo_robo.shuffle()
	mazo_descarte.clear()
	mano.clear()

	robando = false
	robo_cancelado = false


func iniciar_turno() -> void:
	await robar_cartas(TAMANO_MANO)


# ============================================================
# ROBO Y RECICLAJE
# ============================================================

func robar_cartas(cantidad: int) -> void:
	if cantidad <= 0 or robando or robo_cancelado:
		return

	robando = true
	estado_robo_actualizado.emit(true)

	await _robar(cantidad)

	robando = false
	estado_robo_actualizado.emit(false)


func _robar(cantidad: int) -> void:
	var pendientes: int = cantidad

	while pendientes > 0 and not robo_cancelado:

		# Reciclar únicamente si se agotó el mazo de robo.
		if mazo_robo.is_empty():
			if mazo_descarte.is_empty():
				break

			var cantidad_reciclada: int = mazo_descarte.size()

			_reciclar_descarte()

			if presentar_reciclaje.is_valid():
				await presentar_reciclaje.call(cantidad_reciclada)

			if robo_cancelado:
				return

		# Robar hasta agotar las cartas disponibles o la solicitud.
		var cantidad_tanda: int = mini(pendientes, mazo_robo.size())
		var nuevas_cartas: Array[CardData] = []

		for i in range(cantidad_tanda):
			var carta_robada: CardData = mazo_robo.pop_back()

			if mano.size() < TAMANO_MANO:
				mano.append(carta_robada)
				nuevas_cartas.append(carta_robada)
			else:
				mazo_descarte.append(carta_robada)

		pendientes -= cantidad_tanda

		# Registrar las cartas nuevas antes de reconstruir la mano.
		if not nuevas_cartas.is_empty():
			cartas_robadas.emit(nuevas_cartas)

		mano_actualizada.emit(mano)

		# Esperar antes de continuar robando o reciclando.
		if presentar_robo.is_valid():
			await presentar_robo.call()

		if robo_cancelado:
			return


func _reciclar_descarte() -> void:
	mazo_robo = mazo_descarte.duplicate()
	mazo_robo.shuffle()
	mazo_descarte.clear()


func cancelar_robo() -> void:
	robo_cancelado = true


# ============================================================
# JUEGO Y DESCARTE
# ============================================================

func descartar_carta(
	indice: int,
	carta: CardData) -> bool:

	if not es_carta_en_indice(indice, carta):
		push_warning("DeckManager: índice de descarte inválido.")
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


func descartar_mano() -> void:
	if mano.is_empty():
		return

	mazo_descarte.append_array(mano)
	mano.clear()

	mano_actualizada.emit(mano)


# ============================================================
# CONSULTAS
# ============================================================

func es_carta_en_indice(
	indice: int,
	carta: CardData) -> bool:

	if indice < 0 or indice >= mano.size():
		return false

	if carta == null:
		return false

	return mano[indice] == carta
