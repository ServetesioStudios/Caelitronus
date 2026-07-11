#GAME_MANAGER
extends Node

const SAVE_PATH := "user://save.tres"


const STATS_PATHS := {
	TipoCaelius.PENA: "res://Data/characters/stats_pena.tres",
	TipoCaelius.IRA: "res://Data/characters/stats_ira.tres",
	TipoCaelius.EGO: "res://Data/characters/stats_ego.tres",
}

const CANTIDAD_MONAGUILLOS_POR_RUN := 2
const MONAGUILLOS :  Array[String] = [
	"res://Scenes/enemigos/monaguillo_sagrado.tscn",
	"res://Scenes/enemigos/monaguillo_oscuro.tscn",
	"res://Scenes/enemigos/monaguillo_lazaro.tscn",
]
const BOSS_SCENE := "res://Scenes/enemigos/boss_padre_espina.tscn"


const MAZOS_INICIALES := {
	TipoCaelius.IRA: {
		"golpe_basico": 2, "golpe_fuerte": 4, "escudo": 1, "recuperar_energia": 3,
	},
	TipoCaelius.EGO: {
		"golpe_basico": 3, "golpe_fuerte": 1, "escudo": 4, "recuperar_energia": 2,
	},
	TipoCaelius.PENA: {
		"golpe_basico": 3, "golpe_fuerte": 2, "escudo": 1, "recuperar_energia": 2,
		"curacion_menor": 2,
	},
}


var player_data: PlayerData
enum TipoCaelius { PENA, IRA, EGO }
enum Jefe { ESPINA, SERPICO, EIRENE, CORVUS, GALAAD, KAPPARAH }

var secuencia_combates: Array[String] = []
var combate_actual: int = 1

func _ready() -> void:
	MusicManager.play_menu()
	
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
	player_data.hp_actual = -1
	iniciar_secuencia_combates()
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

func marcar_jefe_derrotado(id: Jefe) -> void:
	if player_data == null:
		return
	player_data.jefes_derrotados[id] = true
	guardar_partida()

func avanzar_combate() -> void: 
	combate_actual += 1
	
func reiniciar_secuencia_combates() -> void:
	iniciar_secuencia_combates()

func iniciar_secuencia_combates() -> void:
	secuencia_combates.clear()
	var monaguillos_mezclados := MONAGUILLOS.duplicate()
	monaguillos_mezclados.shuffle()
	#secuencia_combates = monaguillos_mezclados #para agregar todos los monaguillos 
	secuencia_combates.append_array(monaguillos_mezclados.slice(0, CANTIDAD_MONAGUILLOS_POR_RUN))
	secuencia_combates.append(BOSS_SCENE)
	combate_actual = 1

func obtener_escena_enemigo_actual() -> String:
	return secuencia_combates[combate_actual - 1]
	
func combate_actual_es_ultimo() -> bool:
	return combate_actual >= secuencia_combates.size()


func crear_mazo_inicial(tipo: TipoCaelius) -> Array[CardData]:
	var mazo: Array[CardData] = []
	var composicion: Dictionary = MAZOS_INICIALES.get(tipo, {})
	for nombre_carta in composicion.keys():
		var cantidad: int = composicion[nombre_carta]
		var carta: CardData = load("res://Data/cartas/%s.tres" % nombre_carta)
		for i in cantidad:
			mazo.append(carta)
	return mazo

#DECK DE PRUEBA
#func crear_mazo_inicial() -> Array[CardData]:
	#var mazo: Array[CardData] = []
	#var ruta = "res://Data/cartas/"
	#for i in 3: 
		#mazo.append(load(ruta + "/golpe_basico.tres"))
	#for i in 3:
		#mazo.append(load(ruta + "/golpe_fuerte.tres"))
	#for i in 2: 
		#mazo.append(load(ruta+"/escudo.tres"))
	#for i in 2: 
		#mazo.append(load(ruta + "recuperar_energia.tres"))
	##for i in 2: 
		##mazo.append(load(ruta+"/sangrado.tres"))
	#return mazo
