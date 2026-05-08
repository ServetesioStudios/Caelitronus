extends Node2D

# IDENTIDAD
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

# BONUS
var bonus_daño = 1.0
var bonus_defensa = 1.0
var bonus_velocidad = 1.0

var robo_vida = false
var doble_golpe = false
var inmune = false

# HABILIDADES
var puede_revivir = true
var cooldown_habilidad = 0.0

# COMBATE
var tiempo_ataque = 0.0
var vida_tween = null

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
	cargar_sprite()
	actualizar_barra_vida()

	if has_node("AnimationPlayer"):
		if $AnimationPlayer.has_animation("idle"):
			$AnimationPlayer.play("idle")

# PROCESS
func _process(delta):

	tiempo_ataque -= delta
	cooldown_habilidad -= delta

	match tipo:
		"monaquillo_sagrado":
			habilidad_sagrado()

		"monaquillo_oscuro":
			habilidad_oscuro()

# ATAQUE
func puede_atacar():
	return tiempo_ataque <= 0 and hp > 0

func reiniciar_tiempo():
	tiempo_ataque = 1.0 / velocidad

# RECIBIR DAÑO
func recibir_daño(cantidad):

	if hp <= 0:
		return

	hp -= cantidad

	print(nombre + " recibe " + str(cantidad))

	actualizar_barra_vida()

	# REVIVIR
	if hp <= 0:

		if tipo == "monaquillo_lazaro" and puede_revivir:
			revivir()
		else:
			morir()

# REVIVIR
func revivir():

	puede_revivir = false
	hp = int(max_hp * 0.5)

	print(nombre + " revive!")

	actualizar_barra_vida()

# MORIR
func morir():

	print(nombre + " murió")

	queue_free()

# RANDOM
func elegir_tipo_random():

	var r = randi() % 100

	if r < 40:
		tipo = "monaquillo_sagrado"

	elif r < 80:
		tipo = "monaquillo_oscuro"

	else:
		tipo = "monaquillo_lazaro"

# HABILIDAD SAGRADO
func habilidad_sagrado():

	if cooldown_habilidad > 0:
		return

	var cura = int(max_hp * 0.05)

	hp += cura
	hp = min(hp, max_hp)

	actualizar_barra_vida()

	print(nombre + " se cura " + str(cura))

	cooldown_habilidad = 3.0

# HABILIDAD OSCURO
func habilidad_oscuro():

	if cooldown_habilidad > 0:
		return

	var chance = randi() % 100

	if chance < 30:
		bonus_daño = 1.5
		print(nombre + " entra en furia!")
	else:
		bonus_daño = 1.0

	cooldown_habilidad = 2.0

# CARGAR ENEMIGO
func cargar_enemigo():

	match tipo:

		"monaquillo_sagrado":
			nombre = "Monaquillo Sagrado"
			stats_monaquillo_sagrado()

		"monaquillo_oscuro":
			nombre = "Monaquillo Oscuro"
			stats_monaquillo_oscuro()

		"monaquillo_lazaro":
			nombre = "Monaquillo Lázaro"
			stats_monaquillo_lazaro()

# BARRA VIDA
func actualizar_barra_vida():

	if not has_node("HealthBar"):
		return

	var barra = $HealthBar

	var porcentaje = float(hp) / float(max_hp) * 100.0

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

# SPRITE
func cargar_sprite():

	if not has_node("Sprite2D"):
		return

	var sprite = $Sprite2D

	match tipo:

		"monaquillo_sagrado":
			sprite.texture = sprite_sagrado

		"monaquillo_oscuro":
			sprite.texture = sprite_oscuro

		"monaquillo_lazaro":
			sprite.texture = sprite_lazaro

# NUEVO BALANCE DE STATS
# SAGRADO
func stats_monaquillo_sagrado():

	aplicar_stats([
		[90,6,4,10,12,20,5],
		[130,8,6,12,15,25,8],
		[180,10,8,15,18,30,10],
		[240,13,10,18,22,40,15],
		[320,16,12,20,25,50,20]
	][nivel - 1])

# OSCURO
func stats_monaquillo_oscuro():

	aplicar_stats([
		[80,10,2,8,14,0,10],
		[120,14,4,10,18,0,15],
		[170,18,6,12,22,0,20],
		[230,24,8,15,26,0,28],
		[300,30,10,18,30,0,35]
	][nivel - 1])

# LAZARO
func stats_monaquillo_lazaro():

	aplicar_stats([
		[120,5,8,5,8,10,5],
		[180,8,12,8,10,15,8],
		[250,12,16,10,12,20,12],
		[340,16,20,12,15,25,18],
		[450,20,25,15,18,30,25]
	][nivel - 1])

# APLICAR STATS
func aplicar_stats(s):

	max_hp = s[0]
	hp = s[0]

	daño = s[1]
	defensa = s[2]
	esquive = s[3]

	# NUEVO BALANCE VELOCIDAD
	velocidad = s[4] / 25.0

	fe = s[5]
	poder = s[6]
