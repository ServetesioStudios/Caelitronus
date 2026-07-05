extends Node

const SAVE_PATH := "user://save.tres"

const STATS_PATHS := {
	TipoCaelius.PENA: "res://Data/characters/stats_pena.tres",
	TipoCaelius.IRA: "res://Data/characters/stats_ira.tres",
	TipoCaelius.EGO: "res://Data/characters/stats_ego.tres",
}

var player_data: PlayerData


enum TipoCaelius { PENA, IRA, EGO }
enum Jefe { ESPINA, SERPICO, EIRENE, CORVUS, GALAAD, KAPPARAH }


func get_stats_for(tipo: TipoCaelius) -> Stats:
	var path: String = STATS_PATHS.get(tipo, "")
	if path == "":
		push_error("GameManager: no hay Stats registrado para el tipo: %s" % tipo)
		return null
	var resource = load(path)
	if resource == null:
		push_error("GameManager: no se pudo cargar el archivo %s" % path)
		return null
	return load(path).duplicate()

func iniciar_nueva_partida(tipo: TipoCaelius) -> void:
	player_data = PlayerData.new()
	player_data.tipo_caelius = tipo
	player_data.nivel = 1
	guardar_partida()
	
func hay_partida_guardada() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
	
func guardar_partida() -> void:
	if player_data == null:
		push_error("GameManager: no hay player_data para guardar")
		return
	var err := ResourceSaver.save(player_data, SAVE_PATH)
	if err != OK:
		push_error("GameManager: fallo al guardar partida (error %s)" % err)
		
func cargar_partida() -> void:
	if not hay_partida_guardada():
		push_error("GameManager: no hay partida guardada para cargar")
		return
	var loaded = ResourceLoader.load(SAVE_PATH)
	if loaded is PlayerData:
		player_data = loaded
	else:
		push_error("GameManager: el archivo de guardado no es un PlayerData válido")
	
func borrar_partida() -> void:
	if hay_partida_guardada():
		DirAccess.remove_absolute(SAVE_PATH)
	player_data = null

func es_jefe_derrotado(id: int) -> bool:
	if player_data == null:
		return false
	return player_data.jefes_derrotados.get(id, false)

func marcar_jefe_derrotado(id: String) -> void:
	if player_data == null:
		return
	player_data.jefes_derrotados[id] = true
	guardar_partida()
