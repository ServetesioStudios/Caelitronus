extends Node2D

var nombre = "Caelius"

var hp = 100
var max_hp = 100

var daño = 10
var defensa = 10
var esquive = 10
var velocidad = 1.0

var fe = 0
var poder = 0

# COMBATE
var tiempo_ataque = 0.0


# PROGRESO
var tipo_caelius = "ira"  
var nivel = 1

func _ready():
	randomize()
	cargar_progreso()
	cargar_stats()
	
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("idle")


# PROCESS
func _process(delta):
	tiempo_ataque -= delta


# ATAQUE
func puede_atacar():
	return tiempo_ataque <= 0 and hp > 0

func reiniciar_tiempo():
	tiempo_ataque = 1.0 / velocidad

# CARGAR CFG
func cargar_progreso():
	var config = ConfigFile.new()
	var err = config.load("res://cfg/progreso.cfg")

	if err != OK:
		print("No se pudo cargar progreso, usando valores default")
		return

	tipo_caelius = config.get_value("player", "caelius", "ira")
	nivel = config.get_value("player", "nivel", 1)

	print("Caelius elegido:", tipo_caelius)
	print("Nivel:", nivel)


# CARGAR STATS
func cargar_stats():
	match tipo_caelius:
		"ira":
			stats_ira()
		"ego":
			stats_ego()
		"pena":
			stats_pena()
		_:
			print("Tipo desconocido, usando ira")
			stats_ira()


# STATS POR TIPO
# IRA
func stats_ira():
	var stats = [
		[150,10,5,15,10,10,15],
		[300,25,15,25,20,15,30],
		[450,40,25,35,30,20,45],
		[600,55,35,45,40,25,60],
		[750,70,45,55,50,30,75]
	]

	aplicar_stats(stats[nivel - 1])

# EGO
func stats_ego():
	var stats = [
		[200,5,15,5,15,10,5],
		[350,10,30,10,30,20,10],
		[500,15,45,15,45,30,15],
		[650,20,60,20,60,40,20],
		[800,25,75,25,75,50,25]
	]

	aplicar_stats(stats[nivel - 1])

# PENA
func stats_pena():
	var stats = [
		[150,5,5,15,15,20,5],
		[300,10,10,25,25,35,10],
		[450,15,15,35,35,50,15],
		[600,20,20,45,45,65,20],
		[750,25,25,55,55,80,25]
	]

	aplicar_stats(stats[nivel - 1])


# APLICAR STATS
func aplicar_stats(s):
	max_hp = s[0]
	hp = s[0]
	daño = s[1]
	defensa = s[2]
	esquive = s[3]
	velocidad = s[4] / 10.0  # importante para balance
	fe = s[5]
	poder = s[6]

	print("Stats cargados:")
	print("HP:", hp)
	print("Daño:", daño)
	print("Def:", defensa)
	print("Esquive:", esquive)
	print("Vel:", velocidad)
	print("Fe:", fe)
	print("Poder:", poder)
