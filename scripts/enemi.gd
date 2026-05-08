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
var bonus_daño = 1.3
var bonus_defensa = 1.0
var bonus_velocidad = 1.0

var robo_vida = false
var doble_golpe = false
var inmune = false

# HABILIDADES ENEMIGO
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

	if has_node("AnimationPlayer") and $AnimationPlayer.has_animation("idle"):
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

	# MUERTE O REVIVIR
	if hp <= 0:
		if tipo == "monaquillo_lazaro" and puede_revivir:
			revivir()
		else:
			morir()

# REVIVIR (LÁZARO)
func revivir():
	hp = int(max_hp * 0.5)
	puede_revivir = false

	print("Lázaro revive!")

	actualizar_barra_vida()

# MORIR
func morir():
	print(nombre + " murió")

# RANDOM
func elegir_tipo_random():
	var r = randi() % 100

	if r <= 40:
		tipo = "monaquillo_sagrado"
	elif r < 80 && r > 40:
		tipo = "monaquillo_oscuro"
	else:
		tipo = "monaquillo_lazaro"

# HABILIDADES
# SAGRADO → se cura
func habilidad_sagrado():
	if cooldown_habilidad > 0:
		return

	var cura = int(max_hp * 0.01)
	hp += cura
	hp = min(hp, max_hp)

	actualizar_barra_vida()
	print("Sagrado se cura:", cura)

	cooldown_habilidad = 5.0


# OSCURO → daño extra temporal
func habilidad_oscuro():
	if cooldown_habilidad > 0:
		return

	var chance = randi() % 100

	if chance < 30:
		bonus_daño = 1.5
		print("Oscuro entra en furia!")
	else:
		bonus_daño = 1.0

	cooldown_habilidad = 3.0

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

# BARRA DE VIDA
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

	if porcentaje > 50:
		barra.modulate = Color(0.591, 0.809, 0.51)
	elif porcentaje > 10:
		barra.modulate = Color(0.81, 0.692, 0.377)
	elif porcentaje > 0:
		barra.modulate = Color(0.907, 0.337, 0.268)
	else:
		barra.modulate = Color(1, 1, 1, 0)

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
			
# STATS
func stats_monaquillo_sagrado():
	aplicar_stats([
		[110,10,10,15,10,25,10],
		[200,15,15,20,30,35,15],
		[350,20,20,25,35,45,20],
		[400,25,25,30,40,55,25],
		[550,30,30,35,45,65,30]
	][nivel - 1])

func stats_monaquillo_oscuro():
	aplicar_stats([
		[120,15,5,25,10,0,15],
		[230,25,20,35,25,5,25],
		[300,35,30,45,35,10,35],
		[370,45,40,55,45,15,45],
		[440,55,50,65,55,20,55]
	][nivel - 1])

func stats_monaquillo_lazaro():
	aplicar_stats([
		[100,10,20,10,15,20,10],
		[230,20,35,20,40,35,20],
		[300,30,50,30,55,50,30],
		[370,40,65,40,70,65,40],
		[440,50,80,50,85,80,50]
	][nivel - 1])

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
