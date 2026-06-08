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

# EFECTOS
var robo_vida = false
var doble_golpe = false
var inmune = false

# HABILIDAD
var habilidad_activa = false
var habilidad_timer = 0.0

var cooldown_habilidad = 0.0
var puede_revivir = true

var habilidad_nombre = ""

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

	if cooldown_habilidad > 0:
		cooldown_habilidad -= delta

	if habilidad_activa:

		habilidad_timer -= delta

		if habilidad_timer <= 0:
			desactivar_habilidad()

	# ACTIVAR HABILIDAD
	if hp > 0 and cooldown_habilidad <= 0:

		match tipo:

			# SAGRADO
			"monaquillo_sagrado":

				if hp < max_hp * 0.45:
					activar_habilidad()

			# OSCURO
			"monaquillo_oscuro":

				if hp < max_hp * 0.40:
					activar_habilidad()

			# LAZARO
			"monaquillo_lazaro":

				if hp <= max_hp * 0.15 and puede_revivir:
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

	if inmune:
		return

	hp -= cantidad

	hp = max(hp, 0)

	actualizar_barra_vida()

	# REVIVIR
	if hp <= 0:

		if tipo == "monaquillo_lazaro" and puede_revivir:

			activar_habilidad()

		else:
			morir()

# HABILIDADES
func activar_habilidad():

	if habilidad_activa:
		return

	habilidad_activa = true

	match tipo:

		# SAGRADO
		"monaquillo_sagrado":

			habilidad_nombre = "Último Consuelo"

			habilidad_timer = 4.0

			# MENOS TANQUE
			bonus_defensa = 1.3

			# MENOS CURA
			var cura = int(max_hp * 0.15)

			hp += cura
			hp = min(hp, max_hp)

			actualizar_barra_vida()

			cooldown_habilidad = 20.0

		# OSCURO
		"monaquillo_oscuro":

			habilidad_nombre = "Hambre del Monaguillo"

			habilidad_timer = 6.0

			robo_vida = true

			# MENOS DAÑO
			bonus_daño = 1.25

			cooldown_habilidad = 25.0

		# LAZARO
		"monaquillo_lazaro":

			habilidad_nombre = "Fe Inmortal"

			habilidad_timer = 6.0

			puede_revivir = false

			# REVIVE CON MENOS VIDA
			hp = int(max_hp * 0.55)

			# MENOS DEF
			bonus_defensa = 1.35

			# MENOS FE
			fe += 8

			actualizar_barra_vida()

			cooldown_habilidad = 999.0

# DESACTIVAR
func desactivar_habilidad():

	habilidad_activa = false

	bonus_daño = 1.0
	bonus_defensa = 1.0
	bonus_velocidad = 1.0

	robo_vida = false
	doble_golpe = false
	inmune = false

# MORIR
func morir():

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

# CARGAR ENEMIGO
func cargar_enemigo():

	match tipo:

		# BALANCEADO
		"monaquillo_sagrado":

			nombre = "Monaquillo Sagrado"

			aplicar_stats([
				90,   # HP
				5,    # DAÑO
				5,    # DEF
				6,    # ESQ
				9,    # VEL
				12,   # FE
				5     # PODER
			])

		# RAPIDO PERO FRAGIL
		"monaquillo_oscuro":

			nombre = "Monaquillo Oscuro"

			aplicar_stats([
				80,
				6,
				3,
				10,
				12,
				8,
				6
			])

		# TANQUE LENTO
		"monaquillo_lazaro":

			nombre = "Monaquillo Lazaro"

			aplicar_stats([
				100,
				4,
				7,
				4,
				7,
				15,
				4
			])

# STATS
func aplicar_stats(s):

	max_hp = s[0]
	hp = s[0]

	daño = s[1]
	defensa = s[2]
	esquive = s[3]

	velocidad = s[4] / 10.0

	fe = s[5]
	poder = s[6]

# VIDA
func actualizar_barra_vida():

	if !has_node("HealthBar"):
		return

	var barra = $HealthBar

	var porcentaje = float(hp) / float(max_hp) * 100.0

	if vida_tween != null:
		vida_tween.kill()

	vida_tween = create_tween()

	vida_tween.tween_property(
		barra,
		"value",
		porcentaje,
		0.2
	)

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

# SPRITE
func cargar_sprite():

	if !has_node("Sprite2D"):
		return

	match tipo:

		"monaquillo_sagrado":
			$Sprite2D.texture = sprite_sagrado

		"monaquillo_oscuro":
			$Sprite2D.texture = sprite_oscuro

		"monaquillo_lazaro":
			$Sprite2D.texture = sprite_lazaro
