
extends Node

const SAVE_PATH := "user://save.tres"

const STATS_PATHS := {
	TipoCaelius.PENA: "res://Data/characters/stats_pena.tres",
	TipoCaelius.IRA: "res://Data/characters/stats_ira.tres",
	TipoCaelius.EGO: "res://Data/characters/stats_ego.tres",
}

const MAZOS_INICIALES := {
	TipoCaelius.IRA: {
		"golpe_basico": 2,
		"golpe_fuerte": 4,
		"escudo": 1,
		"recuperar_energia": 3,
	},
	TipoCaelius.EGO: {
		"golpe_basico": 3,
		"golpe_fuerte": 1,
		"escudo": 4,
		"recuperar_energia": 2,
	},
	TipoCaelius.PENA: {
		"golpe_basico": 3,
		"golpe_fuerte": 2,
		"escudo": 1,
		"recuperar_energia": 2,
		"curacion_menor": 2,
	},
}


enum TipoCaelius { PENA, IRA, EGO }
enum Jefe { ESPINA, SERPICO, EIRENE, CORVUS, GALAAD, KAPPARAH }
enum TipoEncuentro { NORMAL, JEFE }


# DATOS DEL JUGADOR Y EXPEDICIÓN

var player_data: PlayerData
var estado_expedicion: EstadoExpedicion = EstadoExpedicion.new()


# DATOS DEL ENCUENTRO ACTUAL

var enemy_data_encuentro: EnemyData = null
var zona_id_encuentro: String = ""
var enemigo_id_encuentro: String = ""
var posicion_jugador_encuentro: Vector2 = Vector2.ZERO
var tipo_encuentro: TipoEncuentro = TipoEncuentro.NORMAL


func _ready() -> void:
	MusicManager.play_menu()


# ESTADÍSTICAS DEL CAELIUS

func get_stats_for(tipo: TipoCaelius) -> Stats:
	var path: String = STATS_PATHS.get(tipo, "")

	if path.is_empty():
		push_error("GameManager: no hay Stats registrado para el tipo %s." % tipo)
		return null

	var recurso := load(path) as Stats

	if recurso == null:
		push_error("GameManager: no se pudo cargar %s." % path)
		return null

	return recurso.duplicate()


# GESTIÓN DE PARTIDAS

func iniciar_nueva_partida(tipo: TipoCaelius) -> void:
	player_data = PlayerData.new()
	player_data.tipo_caelius = tipo
	player_data.nivel = 1
	player_data.hp_actual = -1

	estado_expedicion = EstadoExpedicion.new()

	limpiar_encuentro()
	guardar_partida()


func hay_partida_guardada() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func guardar_partida() -> void:
	if player_data == null:
		push_error("GameManager: no hay PlayerData para guardar.")
		return

	var error := ResourceSaver.save(player_data, SAVE_PATH)

	if error != OK:
		push_error("GameManager: fallo al guardar partida (error %s)." % error)


func cargar_partida() -> void:
	if not hay_partida_guardada():
		push_error("GameManager: no hay partida guardada.")
		return

	var recurso := ResourceLoader.load(SAVE_PATH)

	if recurso is PlayerData:
		player_data = recurso
	else:
		push_error("GameManager: el guardado no es un PlayerData válido.")


func borrar_partida() -> void:
	if hay_partida_guardada():
		var error := DirAccess.remove_absolute(SAVE_PATH)

		if error != OK:
			push_error("GameManager: no se pudo borrar la partida.")
			return

	player_data = null


# PROGRESO PERMANENTE DE JEFES
# Conservar hasta revisar las referencias externas.

func es_jefe_derrotado(id: int) -> bool:
	if player_data == null:
		return false

	return player_data.jefes_derrotados.get(id, false)


func marcar_jefe_derrotado(id: Jefe) -> void:
	if player_data == null:
		return

	player_data.jefes_derrotados[id] = true
	guardar_partida()


# MAZO INICIAL

func crear_mazo_inicial(tipo: TipoCaelius) -> Array[CardData]:
	var mazo: Array[CardData] = []
	var composicion: Dictionary = MAZOS_INICIALES.get(tipo, {})

	for nombre_carta in composicion.keys():
		var cantidad: int = composicion[nombre_carta]
		var carta := load("res://Data/cartas/%s.tres" % nombre_carta) as CardData

		if carta == null:
			push_error("GameManager: no se pudo cargar la carta %s." % nombre_carta)
			continue

		for i in range(cantidad):
			mazo.append(carta)

	return mazo


# GESTIÓN DE ENCUENTROS

func preparar_encuentro(
	datos: EnemyData,
	zona_id: String,
	enemigo_id: String,
	posicion_jugador: Vector2,
	tipo: TipoEncuentro = TipoEncuentro.NORMAL
) -> void:
	if datos == null:
		push_error("GameManager: no se puede iniciar un encuentro sin EnemyData.")
		return

	if zona_id.strip_edges().is_empty() or enemigo_id.strip_edges().is_empty():
		push_error("GameManager: el encuentro necesita una zona y un ID válidos.")
		return

	enemy_data_encuentro = datos
	zona_id_encuentro = zona_id
	enemigo_id_encuentro = enemigo_id
	posicion_jugador_encuentro = posicion_jugador
	tipo_encuentro = tipo


func limpiar_encuentro() -> void:
	enemy_data_encuentro = null
	zona_id_encuentro = ""
	enemigo_id_encuentro = ""
	posicion_jugador_encuentro = Vector2.ZERO
	tipo_encuentro = TipoEncuentro.NORMAL
