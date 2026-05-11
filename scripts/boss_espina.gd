extends Node2D

# IDENTIDAD
var nombre = "Padre Espina"

# VIDA
var hp = 420
var max_hp = 420

# STATS BALANCEADOS
var daño = 11
var defensa = 8
var esquive = 6
var velocidad = 1.0

var fe = 28
var poder = 14

# BONUS
var bonus_daño = 1.0
var bonus_defensa = 1.0
var bonus_velocidad = 1.0

# EFECTOS
var veneno_activo = false
var habilidad_activa = false
var inmune = false

# HABILIDAD
var habilidad_nombre = "Éxtasis Prohibido"

var habilidad_timer = 0.0
var cooldown_habilidad = 12.0

# COMBATE
var tiempo_ataque = 0.0

# VISUAL
var vida_tween = null
var fase_desesperacion = false

# TEMBLOR
var posicion_original = Vector2.ZERO

# READY
func _ready():

	posicion_original = position

	actualizar_barra_vida()

	# ANIMACION IDLE
	if has_node("AnimationPlayer"):

		if $AnimationPlayer.has_animation("idle"):

			$AnimationPlayer.play("idle")

# PROCESS
func _process(delta):

	tiempo_ataque -= delta

	# COOLDOWN
	if cooldown_habilidad > 0:

		cooldown_habilidad -= delta

	# TIEMPO HABILIDAD
	if habilidad_activa:

		habilidad_timer -= delta

		if habilidad_timer <= 0:

			desactivar_habilidad()

	# ACTIVAR HABILIDAD
	if cooldown_habilidad <= 0:

		if hp <= max_hp * 0.75:

			activar_habilidad()

	# FASE FINAL
	if hp <= max_hp * 0.25:

		if !fase_desesperacion:

			activar_fase_desesperacion()

		temblar()

# ATAQUE
func puede_atacar():

	return (
		tiempo_ataque <= 0 and
		hp > 0
	)

func reiniciar_tiempo():

	tiempo_ataque = 1.0 / (
		velocidad * bonus_velocidad
	)

# RECIBIR DAÑO
func recibir_daño(cantidad):

	if hp <= 0:
		return

	if inmune:
		return

	hp -= cantidad

	hp = max(hp, 0)

	actualizar_barra_vida()

	# FLASH DAÑO
	modulate = Color(
		1.0,
		0.5,
		0.5,
		1.0
	)

	await get_tree().create_timer(0.08).timeout

	# SI NO ESTA EN FASE FINAL
	if !fase_desesperacion:

		modulate = Color(1,1,1,1)

	# MUERTE
	if hp <= 0:

		morir()

# HABILIDAD
func activar_habilidad():

	if habilidad_activa:
		return

	habilidad_activa = true

	habilidad_timer = 5.0

	cooldown_habilidad = 25.0

	# BONUS BALANCEADOS
	bonus_daño = 1.35
	bonus_defensa = 1.25
	bonus_velocidad = 1.15

	veneno_activo = true

	print(
		nombre +
		" usa " +
		habilidad_nombre
	)

# DESACTIVAR
func desactivar_habilidad():

	habilidad_activa = false

	bonus_daño = 1.0
	bonus_defensa = 1.0
	bonus_velocidad = 1.0

	veneno_activo = false

# FASE FINAL
func activar_fase_desesperacion():

	fase_desesperacion = true

	modulate = Color(
		1.0,
		0.7,
		0.8,
		1.0
	)

	print(
		nombre +
		" entra en desesperación"
	)

# TEMBLAR
func temblar():

	position = posicion_original + Vector2(

		randf_range(-2, 2),

		randf_range(-2, 2)
	)

# MORIR
func morir():

	queue_free()

# BARRA VIDA
func actualizar_barra_vida():

	if !has_node("HealthBar"):
		return

	var barra = $HealthBar

	var porcentaje = (
		float(hp) /
		float(max_hp)
	) * 100.0

	if vida_tween != null:

		vida_tween.kill()

	vida_tween = create_tween()

	vida_tween.tween_property(

		barra,

		"value",

		porcentaje,

		0.2
	)

	# COLOR VIDA
	if porcentaje > 50:

		barra.modulate = Color(
			0.591,
			0.809,
			0.51
		)

	elif porcentaje > 20:

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
