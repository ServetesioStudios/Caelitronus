extends Node2D


# ============================================================
# REFERENCIAS A NODOS
# ============================================================

@onready var combat_manager := $CombatManager
@onready var deck_manager := $DeckManager

@onready var btn_fin_turno := $CanvasLayer/BtnFinTurno
@onready var player := $CanvasLayer/player
@onready var mano_ui := $CanvasLayer/Mano
@onready var zona_drop := $CanvasLayer/DropZone

@onready var texto_combate := $CanvasLayer/textocombate
@onready var label_energia := $CanvasLayer/LabelEnergia
@onready var label_combates := $CanvasLayer/LabelCombates


# ============================================================
# VARIABLES
# ============================================================

var enemy: Enemy

var historial_texto := ""
var max_lineas := 18

var arrastrando_carta := false


# ============================================================
# INICIALIZACIÓN
# ============================================================

func _ready() -> void:
	MusicManager.play_battle()

	# --------------------------------------------------------
	# Crear enemigo
	# --------------------------------------------------------

	var ruta_enemigo := GameManager.obtener_escena_enemigo_actual()

	label_combates.text = "Combate actual: %d / %d" % [
			GameManager.combate_actual,
			GameManager.secuencia_combates.size()]
	print(
		"Combate actual: %d / %d | Ruta: %s"
		% [
			GameManager.combate_actual,
			GameManager.secuencia_combates.size(),
			ruta_enemigo
		]
	)

	var escena: PackedScene = load(ruta_enemigo)

	enemy = escena.instantiate()
	$CanvasLayer.add_child(enemy)

	enemy.position = Vector2(965, 100)


	# --------------------------------------------------------
	# Conectar DropZone
	# --------------------------------------------------------

	zona_drop.carta_soltada.connect(_on_carta_soltada)


	# --------------------------------------------------------
	# Configurar enemigos
	# --------------------------------------------------------

	var enemigos: Array[Enemy] = [enemy]


	# --------------------------------------------------------
	# Configurar mazo y mano
	# --------------------------------------------------------

	deck_manager.iniciar_mazo(
		GameManager.crear_mazo_inicial(player.tipo_caelius)
	)

	mano_ui.player_ref = player

	deck_manager.mano_actualizada.connect(
		mano_ui.mostrar_mano
	)


	# --------------------------------------------------------
	# Eventos del turno
	# --------------------------------------------------------

	combat_manager.turno_jugador_iniciado.connect(
		deck_manager.iniciar_turno
	)

	combat_manager.turno_jugador_iniciado.connect(
		func():
			btn_fin_turno.disabled = false
	)

	combat_manager.turno_enemigo_iniciado.connect(
		func():
			btn_fin_turno.disabled = true
	)


	# --------------------------------------------------------
	# Eventos del combate
	# --------------------------------------------------------

	combat_manager.combate_terminado.connect(
		_on_combate_terminado
	)

	combat_manager.enemigo_actuo.connect(
		func(enemigo):
			enemigo.reproducir_animacion(
				enemigo.obtener_nombre_animacion_intencion()
			)
	)

	combat_manager.accion_enemigo_realizada.connect(
		_on_accion_enemigo_realizada
	)


	# --------------------------------------------------------
	# Eventos del jugador
	# --------------------------------------------------------

	player.energia_actualizada.connect(
		_actualizar_label_energia
	)

	player.energia_actualizada.connect(
		func(_a, _m):
			mano_ui.actualizar_disponibilidad_todas()
	)


	# --------------------------------------------------------
	# Botón finalizar turno
	# --------------------------------------------------------

	btn_fin_turno.pressed.connect(
		combat_manager.finalizar_turno_jugador
	)


	# --------------------------------------------------------
	# Iniciar combate
	# --------------------------------------------------------

	combat_manager.iniciar_combate(
		player,
		enemigos
	)


# ============================================================
# PROCESAMIENTO DEL DRAG DE CARTAS
# ============================================================

func _process(_delta: float) -> void:
	var drag_data = get_viewport().gui_get_drag_data()

	if drag_data is CardData:
		if not arrastrando_carta:
			arrastrando_carta = true
			_actualizar_gris_por_carta(drag_data)

	else:
		if arrastrando_carta:
			arrastrando_carta = false
			_resetear_gris()


# ============================================================
# INDICADOR VISUAL DE OBJETIVOS VÁLIDOS
# ============================================================

func _actualizar_gris_por_carta(carta: CardData) -> void:
	match carta.tipo_objetivo:

		CardData.TipoObjetivo.PROPIO:
			_set_gris(enemy, true)
			_set_gris(player, false)


		CardData.TipoObjetivo.ENEMIGO_FIJO, \
		CardData.TipoObjetivo.ENEMIGO_CUALQUIERA:
			_set_gris(player, true)
			_set_gris(enemy, false)


		CardData.TipoObjetivo.LIBRE:
			_set_gris(player, false)
			_set_gris(enemy, false)


func _resetear_gris() -> void:
	if player != null:
		_set_gris(player, false)
	if enemy != null:
		_set_gris(enemy, false)


func _set_gris(entidad: CombatEntity, activar: bool) -> void:
	if not is_instance_valid(entidad):
		return

	entidad.modulate = (
		Color(0.5, 0.5, 0.5, 1.0)
		if activar
		else entidad.color_base
	)


# ============================================================
# LÓGICA DE CARTAS
# ============================================================

func _on_carta_soltada(carta: CardData, posicion_global: Vector2) -> void:

	var objetivo := _resolver_objetivo(
		carta,
		posicion_global
	)

	if objetivo == null:
		return

	intentar_jugar_carta(
		carta,
		objetivo
	)


func _resolver_objetivo(
	carta: CardData,
	posicion_global: Vector2
) -> CombatEntity:

	match carta.tipo_objetivo:

		CardData.TipoObjetivo.PROPIO:
			return player


		CardData.TipoObjetivo.ENEMIGO_FIJO:
			return enemy


		CardData.TipoObjetivo.ENEMIGO_CUALQUIERA:
			return _entidad_mas_cercana(
				posicion_global,
				[enemy]
			)


		CardData.TipoObjetivo.LIBRE:
			return _entidad_mas_cercana(
				posicion_global,
				[player, enemy]
			)


	return null


func _entidad_mas_cercana(
	posicion_global: Vector2,
	candidatos: Array
) -> CombatEntity:

	var mejor: CombatEntity = null
	var mejor_dist := INF

	for c in candidatos:

		if not is_instance_valid(c):
			continue

		var dist = c.global_position.distance_to(
			posicion_global
		)

		if dist < mejor_dist:
			mejor_dist = dist
			mejor = c

	return mejor


func intentar_jugar_carta(carta: CardData, objetivo: CombatEntity) -> void:

	if not combat_manager.es_turno_jugador():
		print("No es tu turno")
		return


	if not player.puede_pagar(carta.costo):
		print(
			"No tienes energía suficiente para %s"
			% carta.nombre
		)
		return

	if carta.efectos.size() == 1 and carta.efectos[0] is EnergyEffectData:
		if player.energia_actual >= player.energia_max:
			return
	# --------------------------------------------------------
	# Pagar carta
	# --------------------------------------------------------

	player.gastar_energia(carta.costo)


	# --------------------------------------------------------
	# Ejecutar carta
	# --------------------------------------------------------

	carta.jugar(player,objetivo)


	# --------------------------------------------------------
	# Eliminar carta de la mano
	# --------------------------------------------------------

	deck_manager.jugar_carta(carta)


	# --------------------------------------------------------
	# Animación del jugador
	# --------------------------------------------------------

	player.reproducir_animacion(carta.animacion)


	# --------------------------------------------------------
	# Actualizar UI
	# --------------------------------------------------------

	mostrar_texto(
		"%s juega %s"
		% [
			player.nombre,
			carta.nombre
		]
	)

	# --------------------------------------------------------
	# Comprobar fin de combate
	# --------------------------------------------------------

	if combat_manager.verificar_fin_combate():
		return


# ============================================================
# TEXTO DEL COMBATE
# ============================================================

func mostrar_texto(texto: String) -> void:
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


# ============================================================
# UI - ENERGÍA
# ============================================================

func _actualizar_label_energia(actual: int, maxima: int) -> void:
	
	label_energia.text = (
		"Energía: %d / %d" % [actual,maxima])


# ============================================================
# EVENTOS DEL COMBATE
# ============================================================

func _on_accion_enemigo_realizada(
	enemigo: Enemy,
	descripcion: String
) -> void:

	mostrar_texto(
		descripcion
	)

func _on_combate_terminado(
	victoria: bool
) -> void:

	if victoria:
		#Si queremos después agregar que se cure fuera de combate: GameManager.player_data.hp_actual = player.hp
		GameManager.player_data.hp_actual = player.max_hp 
		GameManager.guardar_partida()


	var overlay = SceneManager.add_overlay(
		SceneManager.SceneID.FIN_PARTIDA,
		$CanvasLayer
	)

	var es_ultimo_combate = (
		GameManager.combate_actual_es_ultimo()
	)

	overlay.configurar(
		victoria,
		es_ultimo_combate
	)
