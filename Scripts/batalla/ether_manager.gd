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
