
extends Node

const SAVE_PATH := "user://save.tres"
const EXPEDICION_SAVE_PATH := "user://expedicion.tres"

const STATS_PATHS := {
	TipoCaelius.PENA: "res://Data/characters/stats_pena.tres",
	TipoCaelius.IRA: "res://Data/characters/stats_ira.tres",
	TipoCaelius.EGO: "res://Data/characters/stats_ego.tres",
}

const MAZOS_INICIALES := {
	TipoCaelius.IRA: {
	"golpe_basico": 3,
	"golpe_fuerte": 3,
	"golpe_rojo_masDanoPocaVida": 3,
	"golpe_rojo_consumeVida": 3,
	"escudo_basico": 3,
	"escudo_fuerte": 3,
	"defensa_verde_masEscudoSiNoTomaDano": 3,
	"defensa_verde_fuerte": 3,
	"daño_cura_rojo_violeta": 3,
	"cura_violeta_MasCuraConPocaVida": 3, 
	"robo_rosa": 5,
	},
	TipoCaelius.EGO: {
		"golpe_basico": 4, 
		"golpe_fuerte":2, 
		"escudo_basico":4, 
		"escudo_fuerte":2
	},
	TipoCaelius.PENA: {
		"golpe_basico": 4, 
		"golpe_fuerte":2, 
		"escudo_basico":4, 
		"escudo_fuerte":2
	},
}


enum TipoCaelius { PENA, IRA, EGO }
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
	player_data.run_id = str(ResourceUID.create_id())
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



func cargar_partida() -> bool:
	if not hay_partida_guardada():
		push_error("No existe una partida guardada.")
		return false

	if not hay_expedicion_guardada():
		push_error("No existe una expedición guardada.")
		return false

	# Cargar los datos del jugador.
	var recurso_jugador := ResourceLoader.load(
		SAVE_PATH,
		"",
		ResourceLoader.CACHE_MODE_IGNORE
	)

	if not recurso_jugador is PlayerData:
		push_error("El archivo no contiene datos válidos del jugador.")
		return false

	# Cargar los datos de la expedición.
	var recurso_expedicion := ResourceLoader.load(
		EXPEDICION_SAVE_PATH,
		"",
		ResourceLoader.CACHE_MODE_IGNORE
	)

	if not recurso_expedicion is ExpedicionSaveData:
		push_error("El archivo no contiene datos válidos de expedición.")
		return false

	if recurso_expedicion.version != 1:
		push_error("Versión de guardado de expedición no compatible.")
		return false

	# Comprobar que ambos archivos pertenecen a la misma run.
	if recurso_jugador.run_id.is_empty():
		push_error("La partida no tiene un identificador de run válido.")
		return false

	if recurso_jugador.run_id != recurso_expedicion.run_id:
		push_error("Los archivos de guardado pertenecen a runs diferentes.")
		return false

	# Reconstruir la expedición.
	var expedicion_cargada := EstadoExpedicion.new()

	if not expedicion_cargada.cargar_datos_guardado(recurso_expedicion):
		push_error("No se pudo reconstruir la expedición.")
		return false

	player_data = recurso_jugador
	estado_expedicion = expedicion_cargada

	limpiar_encuentro()

	print("Partida y expedición cargadas correctamente.")
	return true


func borrar_partida() -> void:
	for ruta in [SAVE_PATH, EXPEDICION_SAVE_PATH]:
		if FileAccess.file_exists(ruta):
			var error := DirAccess.remove_absolute(ruta)

			if error != OK:
				push_error("No se pudo eliminar el archivo: %s" % ruta)
				return

	player_data = null
	estado_expedicion = EstadoExpedicion.new()
	limpiar_encuentro()

	print("Partida y expedición reiniciadas correctamente.")


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
	
	

func guardar_expedicion() -> bool:
	if estado_expedicion == null:
		push_error("No existe un estado de expedición para guardar.")
		return false

	var datos := estado_expedicion.crear_datos_guardado()

	if datos == null:
		push_error("No se pudieron preparar los datos de expedición.")
		return false
		
	if player_data == null or player_data.run_id.is_empty():
		push_error("No existe un identificador de run válido.")
		return false

	datos.run_id = player_data.run_id

	var error := ResourceSaver.save(datos, EXPEDICION_SAVE_PATH)

	if error != OK:
		push_error("Error al guardar la expedición: %s" % error)
		return false

	print("Expedición guardada correctamente.")
	return true


func cargar_expedicion() -> bool:
	if not FileAccess.file_exists(EXPEDICION_SAVE_PATH):
		push_warning("No existe una expedición guardada.")
		return false

	var recurso := ResourceLoader.load(
		EXPEDICION_SAVE_PATH,
		"",
		ResourceLoader.CACHE_MODE_IGNORE
	)

	if not recurso is ExpedicionSaveData:
		push_error("El archivo no contiene datos válidos de expedición.")
		return false

	if recurso.version != 1:
		push_error("Versión de guardado de expedición no compatible.")
		return false

	var expedicion_cargada := EstadoExpedicion.new()

	if not expedicion_cargada.cargar_datos_guardado(recurso):
		push_error("No se pudo reconstruir la expedición.")
		return false

	estado_expedicion = expedicion_cargada

	print("Expedición cargada correctamente.")
	return true


func hay_expedicion_guardada() -> bool:
	return FileAccess.file_exists(EXPEDICION_SAVE_PATH)
