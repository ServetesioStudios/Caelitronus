class_name EtherManager
extends Node

signal eteres_actualizados
signal repeticiones_actualizadas(restantes: int)

enum ColorEter {
	ROJO,
	VIOLETA,
	VERDE,
	ROSA,
	CELESTE
}

const CANTIDAD_ETERES: int = 5
const REPETICIONES_POR_COMBATE: int = 2
const ETER_VACIO: int = -1

var perfil: EtherProfileData = null

var eteres: Array[int] = []
var repeticiones_restantes: int = 0

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


# ============================================================
# COMBATE
# ============================================================

func iniciar_combate(nuevo_perfil: EtherProfileData) -> void:
	if nuevo_perfil == null:
		push_error("EtherManager: falta el perfil de éter.")
		return

	if not nuevo_perfil.es_valido():
		push_error("EtherManager: el perfil no tiene pesos válidos.")
		return

	perfil = nuevo_perfil
	eteres.clear()

	repeticiones_restantes = REPETICIONES_POR_COMBATE

	repeticiones_actualizadas.emit(repeticiones_restantes)
	eteres_actualizados.emit()


# ============================================================
# TURNOS
# ============================================================

func iniciar_turno() -> void:
	if not _perfil_valido():
		push_error("EtherManager: no hay un perfil válido.")
		return

	eteres.clear()

	for i in range(CANTIDAD_ETERES):
		eteres.append(_generar_color())

	eteres_actualizados.emit()


func finalizar_turno() -> void:
	eteres.clear()
	eteres_actualizados.emit()


# ============================================================
# GENERACIÓN DE ÉTER
# ============================================================

func _generar_color() -> int:
	var pesos: Array[int] = perfil.obtener_pesos()
	var total: int = perfil.obtener_peso_total()

	var resultado: int = rng.randi_range(1, total)
	var acumulado: int = 0

	for i in range(pesos.size()):
		acumulado += pesos[i]

		if resultado <= acumulado:
			return i

	return ETER_VACIO


func _perfil_valido() -> bool:
	return perfil != null and perfil.es_valido()


# ============================================================
# REPETICIONES
# ============================================================

func repetir_eteres(indices: Array[int]) -> bool:
	if not _perfil_valido():
		return false

	if repeticiones_restantes <= 0:
		return false

	if indices.is_empty():
		return false

	if eteres.size() != CANTIDAD_ETERES:
		return false

	var indices_unicos: Dictionary = {}

	for indice in indices:
		if indice < 0 or indice >= CANTIDAD_ETERES:
			return false

		if eteres[indice] == ETER_VACIO:
			return false

		indices_unicos[indice] = true

	for indice in indices_unicos.keys():
		eteres[indice] = _generar_color()

	repeticiones_restantes -= 1

	eteres_actualizados.emit()
	repeticiones_actualizadas.emit(repeticiones_restantes)

	return true
	
	
# ============================================================
# VALIDACIÓN DE COSTOS
# ============================================================

func puede_pagar(costo: CardCostData) -> bool:
	if costo == null or not costo.es_costo_valido():
		return false

	var disponibles: Array[int] = eteres.duplicate()
	var especificos: Array[int] = costo.obtener_costos_especificos()

	# Reservar los éteres específicos.
	for color in range(especificos.size()):
		for i in range(especificos[color]):
			var indice: int = disponibles.find(color)

			if indice == -1:
				return false

			disponibles[indice] = ETER_VACIO

	# Contar los éteres restantes para el coste genérico.
	var cantidad_disponible: int = 0

	for eter in disponibles:
		if eter != ETER_VACIO:
			cantidad_disponible += 1

	return cantidad_disponible >= costo.generico
	
# ============================================================
# SELECCIÓN Y CONSUMO DE ÉTERES
# ============================================================


func obtener_indices_especificos(costo: CardCostData) -> Array[int]:
	var indices: Array[int] = []

	if costo == null or not costo.es_costo_valido():
		return indices

	var especificos: Array[int] = costo.obtener_costos_especificos()

	for color in range(especificos.size()):
		var cantidad_necesaria: int = especificos[color]
		var cantidad_encontrada: int = 0

		# Buscar desde la derecha.
		for i in range(eteres.size() - 1, -1, -1):
			if cantidad_encontrada >= cantidad_necesaria:
				break

			if eteres[i] == color and not indices.has(i):
				indices.append(i)
				cantidad_encontrada += 1

	return indices


func pagar_carta(
	costo: CardCostData,
	indices_genericos: Array[int]
) -> bool:
	if not puede_pagar(costo):
		return false

	var indices_especificos: Array[int] = obtener_indices_especificos(costo)

	# Comprobar que se encontraron todos los específicos.
	var cantidad_especificos: int = (
		costo.obtener_costo_total() - costo.generico
	)

	if indices_especificos.size() != cantidad_especificos:
		return false

	# Comprobar la cantidad de genéricos seleccionados.
	if indices_genericos.size() != costo.generico:
		return false

	var indices_consumir: Array[int] = indices_especificos.duplicate()

	for indice in indices_genericos:
		if indice < 0 or indice >= eteres.size():
			return false

		if eteres[indice] == ETER_VACIO:
			return false

		if indices_consumir.has(indice):
			return false

		indices_consumir.append(indice)

	# Consumir solamente después de validar todo.
	for indice in indices_consumir:
		eteres[indice] = ETER_VACIO

	eteres_actualizados.emit()

	return true


func obtener_indices_genericos_disponibles(
	costo: CardCostData) -> Array[int]:

	var indices: Array[int] = []

	if costo == null or not costo.es_costo_valido():
		return indices

	if not puede_pagar(costo):
		return indices

	# Reservar los éteres necesarios para los costes específicos.
	var reservados: Array[int] = obtener_indices_especificos(costo)

	# Obtener los éteres restantes que pueden pagar el coste genérico.
	for i in range(eteres.size()):
		if eteres[i] == ETER_VACIO:
			continue

		if reservados.has(i):
			continue

		indices.append(i)

	return indices
