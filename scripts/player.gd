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

# BONUS COMBATE
var bonus_daño = 1.0
var bonus_defensa = 1.0
var bonus_velocidad = 1.0

# HABILIDADES
var robo_vida = false
var doble_golpe = false
var inmune = false

# COMBATE
var tiempo_ataque = 0.0

# PROGRESO
var tipo_caelius = "ira"
var nivel = 1

# HABILIDAD ESPECIAL
var habilidad_activa = false
var habilidad_timer = 0.0

# VIDA
var vida_tween = null

# READY
func _ready():

	randomize()

	cargar_progreso()
	cargar_stats()

	actualizar_barra_vida()

# PROCESS
func _process(delta):

	tiempo_ataque -= delta

	# HABILIDAD TIMER
	if habilidad_activa:

		habilidad_timer -= delta

		if habilidad_timer <= 0:
			desactivar_habilidad()

	# TEST HABILIDAD
	if Input.is_action_just_pressed("ui_accept"):
		activar_habilidad()

# ATAQUE
func puede_atacar():
	return tiempo_ataque <= 0 and hp > 0

func reiniciar_tiempo():
	tiempo_ataque = 1.0 / (velocidad * bonus_velocidad)

# RECIBIR DAÑO
func recibir_daño(cantidad):

	if hp <= 0:
		return

	hp -= cantidad

	print(nombre + " recibe " + str(cantidad))

	actualizar_barra_vida()

	if hp <= 0:
		morir()

# MORIR
func morir():

	print(nombre + " fue derrotado")

# HABILIDADES
func activar_habilidad():

	if habilidad_activa:
		return

	habilidad_activa = true
	habilidad_timer = 5.0

	match tipo_caelius:

		"ira":
			activar_ira()

		"pena":
			activar_pena()

		"ego":
			activar_ego()

# IRA
func activar_ira():

	bonus_daño = 1.3
	bonus_defensa = 1.2
	bonus_velocidad = 1.2

	print("🔥 Ira del Depredador ACTIVADA")

# PENA
func activar_pena():

	robo_vida = true

	print("🩸 Lamento Parasitario ACTIVADO")

# EGO
func activar_ego():

	doble_golpe = true
	inmune = true

	print("👁 Dominación Absoluta ACTIVADA")

# DESACTIVAR
func desactivar_habilidad():

	habilidad_activa = false

	bonus_daño = 1.0
	bonus_defensa = 1.0
	bonus_velocidad = 1.0

	robo_vida = false
	doble_golpe = false
	inmune = false

	print("Habilidad terminada")

# BARRA VIDA
func actualizar_barra_vida():

	if not has_node("HealthBar"):
		return

	var barra = $HealthBar

	var porcentaje = float(hp) / float(max_hp) * 100.0

	# TWEEN
	if vida_tween != null:
		vida_tween.kill()

	vida_tween = create_tween()
	vida_tween.tween_property(barra, "value", porcentaje, 0.2)

	barra.value = porcentaje

	# COLOR
	if porcentaje > 50:
		barra.modulate = Color(0.591, 0.809, 0.51)

	elif porcentaje > 10:
		barra.modulate = Color(0.81, 0.692, 0.377)

	elif porcentaje > 0:
		barra.modulate = Color(0.907, 0.337, 0.268)

	else:
		barra.modulate = Color(1,1,1,0)

# CFG
func cargar_progreso():

	var config = ConfigFile.new()

	var err = config.load("res://cfg/progreso.cfg")

	if err != OK:
		print("No se pudo cargar progreso")
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

		_:
			stats_ira()

# NUEVO BALANCE DE STATS
# IRA
func stats_ira():

	aplicar_stats([
		[110,8,3,8,10,8,10],
		[170,12,5,10,14,12,15],
		[240,18,8,14,18,16,22],
		[320,24,12,18,22,20,30],
		[420,32,16,22,26,25,40]
	][nivel - 1])

# EGO
func stats_ego():

	aplicar_stats([
		[130,5,8,5,8,10,5],
		[200,8,12,8,12,15,8],
		[280,12,16,10,16,20,12],
		[360,16,22,14,20,25,18],
		[480,22,28,18,24,30,25]
	][nivel - 1])

# PENA
func stats_pena():

	aplicar_stats([
		[100,6,4,12,10,18,6],
		[160,10,6,15,14,25,10],
		[230,14,10,18,18,35,15],
		[310,20,14,22,22,45,22],
		[400,26,18,26,26,55,30]
	][nivel - 1])

# APLICAR STATS
func aplicar_stats(s):

	max_hp = s[0]
	hp = s[0]

	daño = s[1]
	defensa = s[2]
	esquive = s[3]

	# NUEVO BALANCE
	velocidad = s[4] / 25.0

	fe = s[5]
	poder = s[6]

	print("==========")
	print(nombre)
	print("HP:", hp)
	print("Daño:", daño)
	print("Defensa:", defensa)
	print("Esquive:", esquive)
	print("Velocidad:", velocidad)
	print("Fe:", fe)
	print("Poder:", poder)
	print("==========")
