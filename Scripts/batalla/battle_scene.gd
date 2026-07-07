extends Node2D

@onready var combat_manager := $CombatManager
@onready var deck_manager := $DeckManager
@onready var btn_fin_turno := $CanvasLayer/BtnFinTurno

@onready var player = $CanvasLayer/player
@onready var enemy = $CanvasLayer/enemy

# TEXTO
@onready var texto_combate = $CanvasLayer/textocombate

# STATS
@onready var texto_stats_player = $CanvasLayer/playerstatstex
@onready var texto_stats_enemy = $CanvasLayer/enemiplayetex

func _ready():
	var enemigos: Array[Enemy] = [enemy]
	
	var mazo_prueba: Array[CardData] = []
	for i in 5:
		mazo_prueba.append(load("res://Data/cards/golpe.tres"))
	for i in 5:
		mazo_prueba.append(load("res://Data/cards/bloqueo.tres"))
	deck_manager.iniciar_mazo(mazo_prueba)
	
	combat_manager.iniciar_combate(player, enemigos)
	combat_manager.turno_jugador_iniciado.connect(deck_manager.iniciar_turno)

	combat_manager.turno_jugador_iniciado.connect(func(): print("Turno del jugador"))
	combat_manager.turno_enemigo_iniciado.connect(func(): print("Turno del enemigo"))
	combat_manager.combate_terminado.connect(_on_combate_terminado)
	
	deck_manager.mano_actualizada.connect(_debug_mostrar_mano)
	btn_fin_turno.pressed.connect(combat_manager.finalizar_turno_jugador)

func _debug_mostrar_mano(mano: Array[CardData]) -> void:
	print("--- MANO ACTUAL (%d cartas) ---" % mano.size())
	for carta in mano:
		print(" - %s (costo %d)" % [carta.nombre, carta.costo])

func _on_combate_terminado(victoria: bool):
	if victoria:
		print("¡Ganaste!")
	else:
		print("Perdiste")
	
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
	#if atacante.habilidad_activa:
#
		#if !atacante.has_meta(
			#"habilidad_mostrada"
		#):
#
			#mostrar_texto(
				#atacante.nombre +
				#" usa " +
				#atacante.habilidad_nombre
			#)
#
			#atacante.set_meta(
				#"habilidad_mostrada",
				#true
			#)
#
	#else:
#
		#if atacante.has_meta(
			#"habilidad_mostrada"
		#):
#
			#atacante.remove_meta(
				#"habilidad_mostrada"
			#)

	# ATAQUE
	if atacante.puede_atacar():

		atacar(atacante, defensor)

		if is_instance_valid(atacante):

			atacante.reiniciar_tiempo()

# TEXTO
func mostrar_texto(texto: String) -> void:
	if texto_combate == null:
		return
	historial_texto += texto + "\n\n"
	var lineas = historial_texto.split("\n")
	if lineas.size() > max_lineas:
		var nuevas_lineas = []
		for i in range(lineas.size() - max_lineas, lineas.size()):
			nuevas_lineas.append(lineas[i])
		historial_texto = "\n".join(nuevas_lineas)
	texto_combate.text = historial_texto
	await get_tree().process_frame
	if is_instance_valid(texto_combate):
		texto_combate.scroll_to_line(texto_combate.get_line_count())

# STATS UI
func actualizar_stats_ui() -> void:
	if is_instance_valid(player):
		texto_stats_player.text = "ATQ= %s     VEL= %s     PODER= %s\nDEF= %s     ESQ= %s     FE= %s" % [
			player.daño, player.velocidad, player.poder, player.defensa, player.esquive, player.fe
		]
	if is_instance_valid(enemy):
		texto_stats_enemy.text = "ATQ= %s     VEL= %s     PODER= %s\nDEF= %s     ESQ= %s     FE= %s" % [
			enemy.daño, enemy.velocidad, enemy.poder, enemy.defensa, enemy.esquive, enemy.fe
	]
	
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

			defensor.modulate = defensor.color_base

	# MUERTE
	if is_instance_valid(defensor):

		if defensor.hp <= 0:

			mostrar_texto(
				defensor.nombre +
				" fue derrotado"
			)

# ANIMACION
func animar_ataque(atacante: CombatEntity) -> void:
	if !is_instance_valid(atacante):
		return
	var tween = create_tween()
	var posicion_original = atacante.position
	var distancia = 40
	var posicion_ataque = posicion_original + (Vector2(distancia, 0) if atacante == player else Vector2(-distancia, 0))
	tween.tween_property(atacante, "position", posicion_ataque, 0.1)
	tween.tween_property(atacante, "position", posicion_original, 0.1)
