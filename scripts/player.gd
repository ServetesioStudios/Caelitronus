extends Node2D

# IDENTIDAD
var nombre = "Caelius"

# STATS
var hp = 100
var max_hp = 100

var daño = 6
var defensa = 5
var esquive = 5
var velocidad = 1.0

var fe = 0
var poder = 0

# BONUS
var bonus_daño = 1.0
var bonus_defensa = 1.0
var bonus_velocidad = 1.0

# EFECTOS
var robo_vida = false
var doble_golpe = false
var inmune = false

# COMBATE
var tiempo_ataque = 0.0

# PROGRESO
var tipo_caelius = "ira"
var nivel = 1

# HABILIDADES
var habilidad_activa = false
var habilidad_timer = 0.0
var cooldown_habilidad = 0.0
var habilidad_nombre = ""

# READY
func _ready():

	randomize()

	cargar_progreso()
	cargar_stats()
	actualizar_barra_vida()

# PROCESS
func _process(delta):

	tiempo_ataque -= delta

	if cooldown_habilidad > 0:
		cooldown_habilidad -= delta

	if habilidad_activa:

		habilidad_timer -= delta

		if habilidad_timer <= 0:
			desactivar_habilidad()

	# TEST
	if Input.is_action_just_pressed("ui_accept"):

		activar_habilidad()

# ATAQUE
func puede_atacar():

	return tiempo_ataque <= 0 and hp > 0

func reiniciar_tiempo():

	tiempo_ataque = 1.3 / (
		velocidad *
		bonus_velocidad
	)

# HABILIDAD
func activar_habilidad():

	if cooldown_habilidad > 0:
		return

	if habilidad_activa:
		return

	habilidad_activa = true

	match tipo_caelius:

		# IRA
		"ira":

			habilidad_nombre = "Ira del Depredador"

			habilidad_timer = 5.0

			bonus_daño = 1.25
			bonus_defensa = 1.2
			bonus_velocidad = 1.15

		# PENA
		"pena":

			habilidad_nombre = "Lamento Parasitario"

			habilidad_timer = 5.0

			robo_vida = true

		# EGO
		"ego":

			habilidad_nombre = "Dominio Absoluto"

			habilidad_timer = 4.0

			inmune = true
			doble_golpe = true

	cooldown_habilidad = max(
		18.0 - (fe * 0.08),
		10.0
	)

# DESACTIVAR
func desactivar_habilidad():

	habilidad_activa = false

	bonus_daño = 1.0
	bonus_defensa = 1.0
	bonus_velocidad = 1.0

	robo_vida = false
	doble_golpe = false
	inmune = false

# RECIBIR DAÑO
func recibir_daño(cantidad):

	if hp <= 0:
		return

	hp -= cantidad

	hp = max(hp, 0)

	actualizar_barra_vida()

# VIDA
func actualizar_barra_vida():

	if !has_node("HealthBar"):
		return

	var barra = $HealthBar

	var porcentaje = (
		float(hp) /
		float(max_hp)
	) * 100.0

	barra.value = porcentaje

	if porcentaje > 50:

		barra.modulate = Color(
			0.591,
			0.809,
			0.51
		)

	elif porcentaje > 10:

		barra.modulate = Color(
			0.81,
			0.692,
			0.377
		)

	else:

		barra.modulate = Color(
			0.907,
			0.337,
			0.268
		)

# CFG
func cargar_progreso():

	var config = ConfigFile.new()

	var err = config.load(
		"res://cfg/progreso.cfg"
	)

	if err != OK:
		return

	tipo_caelius = config.get_value(
		"player",
		"caelius",
		"ira"
	)

	nivel = config.get_value(
		"player",
		"nivel",
		1
	)

# STATS
func cargar_stats():

	match tipo_caelius:

		"ira":
			stats_ira()

		"ego":
			stats_ego()

		"pena":
			stats_pena()

# IRA
func stats_ira():

	var stats = [
		95,
		7,
		4,
		5,
		10,
		8,
		8
	]

	aplicar_stats(stats)

# EGO
func stats_ego():

	var stats = [
		90,
		5,
		6,
		4,
		9,
		12,
		6
	]

	aplicar_stats(stats)

# PENA
func stats_pena():

	var stats = [
		85,
		6,
		5,
		6,
		9,
		14,
		7
	]

	aplicar_stats(stats)

# APLICAR
func aplicar_stats(s):

	max_hp = s[0]
	hp = s[0]

	daño = s[1]
	defensa = s[2]
	esquive = s[3]

	velocidad = s[4] / 10.0

	fe = s[5]
	poder = s[6]
