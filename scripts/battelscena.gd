extends Node2D

@onready var player = $CanvasLayer/player
@onready var enemy = $CanvasLayer/enemy

# TEXTO
@onready var texto_combate = $CanvasLayer/textocombate

# STATS
@onready var texto_stats_player = $CanvasLayer/playerstatstex
@onready var texto_stats_enemy = $CanvasLayer/enemiplayetex

# HISTORIAL
var historial_texto = ""
var max_lineas = 18

# LOOP
func _process(_delta):

	handle_turn(player, enemy)
	handle_turn(enemy, player)

	actualizar_stats_ui()

# TURNOS
func handle_turn(atacante, defensor):

	if atacante == null:
		return

	if defensor == null:
		return

	if !is_instance_valid(atacante):
		return

	if !is_instance_valid(defensor):
		return

	if atacante.hp <= 0:
		return

	if defensor.hp <= 0:
		return

	# HABILIDAD
	if atacante.habilidad_activa:

		if !atacante.has_meta(
			"habilidad_mostrada"
		):

			mostrar_texto(
				atacante.nombre +
				" usa " +
				atacante.habilidad_nombre
			)

			atacante.set_meta(
				"habilidad_mostrada",
				true
			)

	else:

		if atacante.has_meta(
			"habilidad_mostrada"
		):

			atacante.remove_meta(
				"habilidad_mostrada"
			)

	# ATAQUE
	if atacante.puede_atacar():

		atacar(atacante, defensor)

		if is_instance_valid(atacante):

			atacante.reiniciar_tiempo()

# TEXTO
func mostrar_texto(texto):

	if texto_combate == null:
		return

	historial_texto += texto + "\n\n"

	var lineas = historial_texto.split("\n")

	if lineas.size() > max_lineas:

		var nuevas_lineas = []

		for i in range(
			lineas.size() - max_lineas,
			lineas.size()
		):

			nuevas_lineas.append(
				lineas[i]
			)

		historial_texto = "\n".join(
			nuevas_lineas
		)

	texto_combate.text = historial_texto

	await get_tree().process_frame

	if is_instance_valid(texto_combate):

		texto_combate.scroll_to_line(
			texto_combate.get_line_count()
		)

# STATS UI
func actualizar_stats_ui():

	if is_instance_valid(player):

		var texto_player = ""

		texto_player += "ATQ= " + str(player.daño) + "     "
		texto_player += "VEL= " + str(player.velocidad) + "     "
		texto_player += "PODER= " + str(player.poder) + "\n"

		texto_player += "DEF= " + str(player.defensa) + "     "
		texto_player += "ESQ= " + str(player.esquive) + "     "
		texto_player += "FE= " + str(player.fe)

		texto_stats_player.text = texto_player

	if is_instance_valid(enemy):

		var texto_enemy = ""

		texto_enemy += "ATQ= " + str(enemy.daño) + "     "
		texto_enemy += "VEL= " + str(enemy.velocidad) + "     "
		texto_enemy += "PODER= " + str(enemy.poder) + "\n"

		texto_enemy += "DEF= " + str(enemy.defensa) + "     "
		texto_enemy += "ESQ= " + str(enemy.esquive) + "     "
		texto_enemy += "FE= " + str(enemy.fe)

		texto_stats_enemy.text = texto_enemy

# DAÑO
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

	# INMUNE
	if defensor.inmune:

		mostrar_texto(
			defensor.nombre +
			" es inmune!"
		)

		return 0

	var daño_base = (
		atacante.daño *
		atacante.bonus_daño
	)

	var defensa_base = (
		defensor.defensa *
		defensor.bonus_defensa
	)

	# NUEVO BALANCE
	var daño = (
		daño_base -
		(defensa_base * 0.7)
	)

	var variacion = randf_range(
		0.85,
		1.05
	)

	daño *= variacion

	daño = max(
		int(daño),
		1
	)

	return daño

# EFECTOS
func aplicar_efectos(atacante, defensor, daño):

	if !is_instance_valid(atacante):
		return

	if !is_instance_valid(defensor):
		return

	# DAÑO
	if defensor.has_method(
		"recibir_daño"
	):

		defensor.recibir_daño(daño)

		mostrar_texto(
			defensor.nombre +
			" recibe " +
			str(daño)
		)

	# ROBO VIDA
	if atacante.robo_vida:

		atacante.hp += int(daño * 0.5)

		atacante.hp = min(
			atacante.hp,
			atacante.max_hp
		)

		atacante.actualizar_barra_vida()

		mostrar_texto(
			atacante.nombre +
			" roba vida"
		)

	# DOBLE GOLPE
	if atacante.doble_golpe:

		var daño_extra = int(daño * 0.5)

		if defensor.has_method(
			"recibir_daño"
		):

			defensor.recibir_daño(
				daño_extra
			)

			mostrar_texto(
				"Segundo impacto " +
				str(daño_extra)
			)

# ATAQUE
func atacar(atacante, defensor):

	if !is_instance_valid(atacante):
		return

	if !is_instance_valid(defensor):
		return

	animar_ataque(atacante)

	var daño_final = calcular_daño(
		atacante,
		defensor
	)

	if daño_final <= 0:
		return

	aplicar_efectos(
		atacante,
		defensor,
		daño_final
	)

	# FLASH
	if is_instance_valid(defensor):

		defensor.modulate = Color(
			0.747,
			0.0,
			0.169,
			1.0
		)

		await get_tree().create_timer(0.1).timeout

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

# ANIMACION
func animar_ataque(atacante):

	if !is_instance_valid(atacante):
		return

	var tween = create_tween()

	var posicion_original = atacante.position

	var distancia = 40
	var posicion_ataque

	if atacante == player:

		posicion_ataque = (
			posicion_original +
			Vector2(distancia, 0)
		)

	else:

		posicion_ataque = (
			posicion_original +
			Vector2(-distancia, 0)
		)

	tween.tween_property(
		atacante,
		"position",
		posicion_ataque,
		0.1
	)

	tween.tween_property(
		atacante,
		"position",
		posicion_original,
		0.1
	)
