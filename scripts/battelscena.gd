extends Node2D

@onready var player = $CanvasLayer/player
@onready var enemy = $CanvasLayer/enemy

# TEXTO
@onready var texto_combate = $CanvasLayer/textocombate

# HISTORIAL
var historial_texto = ""

# LIMITE LINEAS
var max_lineas = 18

# LOOP
func _process(_delta):

	handle_turn(player, enemy)
	handle_turn(enemy, player)

# TURNOS
func handle_turn(atacante, defensor):

	if atacante == null or defensor == null:
		return

	if !is_instance_valid(atacante):
		return

	if !is_instance_valid(defensor):
		return

	if atacante.hp <= 0:
		return

	if defensor.hp <= 0:
		return

	if atacante.puede_atacar():

		atacar(atacante, defensor)

		atacante.reiniciar_tiempo()

# TEXTO
func mostrar_texto(texto):

	if texto_combate == null:
		return

	historial_texto += texto + "\n\n"

	var lineas = historial_texto.split("\n")

	# LIMITAR TEXTO
	if lineas.size() > max_lineas:

		var nuevas_lineas = []

		for i in range(
			lineas.size() - max_lineas,
			lineas.size()
		):
			nuevas_lineas.append(lineas[i])

		historial_texto = "\n".join(nuevas_lineas)

	texto_combate.text = historial_texto

	# SCROLL
	await get_tree().process_frame

	if is_instance_valid(texto_combate):
		texto_combate.scroll_to_line(
			texto_combate.get_line_count()
		)

# CALCULAR DAÑO
func calcular_daño(atacante, defensor):

	if !is_instance_valid(atacante):
		return 0

	if !is_instance_valid(defensor):
		return 0

	# ESQUIVE
	var chance = randi() % 100

	if chance < defensor.esquive:

		mostrar_texto(
			defensor.nombre +
			" esquivó!"
		)

		return 0

	# INMUNIDAD
	if defensor.inmune:

		mostrar_texto(
			defensor.nombre +
			" es inmune!"
		)

		return 0

	# DAÑO
	var daño_base = atacante.daño * atacante.bonus_daño

	var defensa_base = defensor.defensa * defensor.bonus_defensa

	var daño = (daño_base * 1.4) - (defensa_base * 0.5)

	# RANDOM
	var variacion = randf_range(0.9, 1.1)

	daño *= variacion

	# MINIMO
	daño = max(int(daño), 1)

	return daño

# EFECTOS
func aplicar_efectos(atacante, defensor, daño):

	if !is_instance_valid(atacante):
		return

	if !is_instance_valid(defensor):
		return

	# RECIBIR DAÑO
	if defensor.has_method("recibir_daño"):

		defensor.recibir_daño(daño)

		mostrar_texto(
			defensor.nombre +
			" recibe " +
			str(daño)
		)

	# ROBO VIDA
	if atacante.robo_vida:

		atacante.hp += daño

		atacante.hp = min(
			atacante.hp,
			atacante.max_hp
		)

		atacante.actualizar_barra_vida()

		mostrar_texto(
			atacante.nombre +
			" roba vida " +
			str(daño)
		)

	# DOBLE GOLPE
	if atacante.doble_golpe:

		mostrar_texto(
			atacante.nombre +
			" hace doble impacto!"
		)

		if defensor.has_method("recibir_daño"):

			defensor.recibir_daño(daño)

			mostrar_texto(
				defensor.nombre +
				" recibe " +
				str(daño)
			)

# ATAQUE
func atacar(atacante, defensor):

	if !is_instance_valid(atacante):
		return

	if !is_instance_valid(defensor):
		return

	# ANIMACIÓN
	animar_ataque(atacante)

	# DAÑO
	var daño_final = calcular_daño(
		atacante,
		defensor
	)

	if daño_final <= 0:
		return

	# EFECTOS
	aplicar_efectos(
		atacante,
		defensor,
		daño_final
	)

	# SI MURIÓ DURANTE EL ATAQUE
	if !is_instance_valid(defensor):
		return

	# FLASH DAÑO
	defensor.modulate = Color(
		0.747,
		0.0,
		0.169,
		1.0
	)

	await get_tree().create_timer(0.1).timeout

	# EVITA ERROR 
	if is_instance_valid(defensor):

		defensor.modulate = Color(
			1,
			1,
			1,
			1
		)

	# MUERTE
	if is_instance_valid(defensor):

		if defensor.hp <= 0:

			mostrar_texto(
				defensor.nombre +
				" fue derrotado"
			)

# ANIMACIÓN
func animar_ataque(atacante):

	if !is_instance_valid(atacante):
		return

	var tween = create_tween()

	var posicion_original = atacante.position

	var distancia = 40

	var posicion_ataque

	# PLAYER
	if atacante == player:

		posicion_ataque = (
			posicion_original +
			Vector2(distancia, 0)
		)

	# ENEMY
	else:

		posicion_ataque = (
			posicion_original +
			Vector2(-distancia, 0)
		)

	# IR
	tween.tween_property(
		atacante,
		"position",
		posicion_ataque,
		0.1
	)

	# VOLVER
	tween.tween_property(
		atacante,
		"position",
		posicion_original,
		0.1
	)
