extends Node2D

var nombre = "Enemigo"

# CONFIG
var tipo = ""
var nivel = 1
var usar_random = true

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

# SPRITES
var sprite_sagrado = preload("res://assets/BttlSprit/sagrados.png")
var sprite_oscuro = preload("res://assets/BttlSprit/oscuro.png")
var sprite_lazaro = preload("res://assets/BttlSprit/lazaro.png")

# READY
func _ready():
	randomize()

	if usar_random:
		elegir_tipo_random()

	cargar_enemigo()
	cargar_sprite()   #cambia el sprite

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

# RANDOM TIPO (40/40/20)
func elegir_tipo_random():
	var r = randi() % 100

	if r < 40:
		tipo = "monaquillo_sagrado"
	elif r < 80:
		tipo = "monaquillo_oscuro"
	else:
		tipo = "monaquillo_lazaro"

	print("Tipo elegido:", tipo)

# CARGAR ENEMIGO
func cargar_enemigo():
	match tipo:
		"monaquillo_sagrado":
			stats_monaquillo_sagrado()
		"monaquillo_oscuro":
			stats_monaquillo_oscuro()
		"monaquillo_lazaro":
			stats_monaquillo_lazaro()
		_:
			print("Tipo no definido, usando sagrado")
			stats_monaquillo_sagrado()

	print("Enemy:", nombre, "| Nivel:", nivel)

# SPRITE SEGÚN TIPO
func cargar_sprite():
	var sprite = $Sprite2D

	match tipo:
		"monaquillo_sagrado":
			sprite.texture = sprite_sagrado
		"monaquillo_oscuro":
			sprite.texture = sprite_oscuro
		"monaquillo_lazaro":
			sprite.texture = sprite_lazaro

# MONAQUILLO SAGRADO
func stats_monaquillo_sagrado():
	nombre = "Monaquillo Sagrado"

	var stats = [
		[150,10,10,15,25,25,10],
		[200,15,15,20,30,35,15],
		[350,20,20,25,35,45,20],
		[400,25,25,30,40,55,25],
		[550,30,30,35,45,65,30]
	]

	aplicar_stats(stats[nivel - 1])

# MONAQUILLO OSCURO
func stats_monaquillo_oscuro():
	nombre = "Monaquillo Oscuro"

	var stats = [
		[160,15,10,25,15,0,15],
		[230,25,20,35,25,5,25],
		[300,35,30,45,35,10,35],
		[370,45,40,55,45,15,45],
		[440,55,50,65,55,20,55]
	]

	aplicar_stats(stats[nivel - 1])

# MONAQUILLO LAZARO
func stats_monaquillo_lazaro():
	nombre = "Monaquillo Lázaro"

	var stats = [
		[100,10,20,10,25,20,10],
		[230,20,35,20,40,35,20],
		[300,30,50,30,55,50,30],
		[370,40,65,40,70,65,40],
		[440,50,80,50,85,80,50]
	]

	aplicar_stats(stats[nivel - 1])

# APLICAR STATS
func aplicar_stats(s):
	max_hp = s[0]
	hp = s[0]
	daño = s[1]
	defensa = s[2]
	esquive = s[3]
	velocidad = s[4] / 10.0
	fe = s[5]
	poder = s[6]

	print("HP:", hp)
	print("Daño:", daño)
	print("Def:", defensa)
	print("Esquive:", esquive)
	print("Vel:", velocidad)
	print("Fe:", fe)
	print("Poder:", poder)
