extends Node2D

# IDENTIDAD
var nombre = "Caelius"

# STATS
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

# HABILIDADES
var habilidad_activa = false
var habilidad_timer = 0.0

var bonus_daño = 1.3
var bonus_defensa = 1.0
var bonus_velocidad = 1.0

var robo_vida = false
var doble_golpe = false
var inmune = false

# READY
func _ready():
	randomize()
	actualizar_barra_vida()

# PROCESS
func _process(delta):
	tiempo_ataque -= delta

	# CONTROL HABILIDAD
	if habilidad_activa:
		habilidad_timer -= delta
		if habilidad_timer <= 0:
			desactivar_habilidad()

	# 🔥 TEST
	if Input.is_action_just_pressed("ui_accept"):
		activar_habilidad()

# ATAQUE
func puede_atacar():
	return tiempo_ataque <= 0 and hp > 0

func reiniciar_tiempo():
	tiempo_ataque = 1.0 / (velocidad * bonus_velocidad)

# HABILIDADES
func activar_habilidad():
	habilidad_activa = true
	habilidad_timer = 5.0

	match tipo_caelius:
		"ira":
			activar_ira()
		"pena":
			activar_pena()
		"ego":
			activar_ego()

func activar_ira():
	bonus_daño = 1.5
	bonus_defensa = 1.5
	bonus_velocidad = 1.5
	print("Ira del Depredador ACTIVADA")

func activar_pena():
	robo_vida = true
	print("Lamento Parasitario ACTIVO")

func activar_ego():
	doble_golpe = true
	inmune = true
	print("Dominación Absoluta ACTIVADA")

func desactivar_habilidad():
	habilidad_activa = false

	bonus_daño = 1.0
	bonus_defensa = 1.0
	bonus_velocidad = 1.0

	robo_vida = false
	doble_golpe = false
	inmune = false

	print("Habilidad terminada")

# BARRA DE VIDA
func actualizar_barra_vida():
	if not has_node("HealthBar"):
		return

	var barra = $HealthBar
	var porcentaje = float(hp) / float(max_hp) * 100.0

	barra.value = porcentaje

	if porcentaje > 50:
		barra.modulate = Color(0.591, 0.809, 0.51)
	elif porcentaje > 10:
		barra.modulate = Color(0.81, 0.692, 0.377)
	elif porcentaje > 0:
		barra.modulate = Color(0.907, 0.337, 0.268)
	else:
		barra.modulate = Color(1, 1, 1, 0)
		

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
		[180,20,5,15,10,10,15],
		[300,25,15,25,20,15,30],
		[450,40,25,35,30,20,45],
		[600,55,35,45,40,25,60],
		[750,70,45,55,50,30,75]
	]

	aplicar_stats(stats[nivel - 1])

# EGO
func stats_ego():
	var stats = [
		[200,15,15,5,15,10,5],
		[350,10,30,10,30,20,10],
		[500,15,45,15,45,30,15],
		[650,20,60,20,60,40,20],
		[800,25,75,25,75,50,25]
	]

	aplicar_stats(stats[nivel - 1])

# PENA
func stats_pena():
	var stats = [
		[150,15,5,15,15,20,5],
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
