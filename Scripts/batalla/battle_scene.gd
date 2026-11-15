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

@onready var label_energia := $CanvasLayer/LabelEnergia
@onready var iconos_energia: HBoxContainer = $CanvasLayer/EnergiaContainer

@onready var ether_manager: EtherManager = $EtherManager
@onready var ether_ui: EtherUI = $CanvasLayer/EtherUI

@onready var aviso_combate: Label = $CanvasLayer/AvisoCombate

#EFECTOS DE CARTAS
var esperando_descarte_efecto: bool = false


# ============================================================
# VARIABLES
# ============================================================

var enemy: Enemy

var historial_texto := ""
var max_lineas := 18

var arrastrando_carta := false

# Carta pendiente de pagar con éteres genéricos.
var carta_pendiente: CardData = null
var objetivo_pendiente: CombatEntity = null

var tween_aviso: Tween

const ICONO_ENERGIA := preload("res://Assets/Icons/poder.png")


# ============================================================
# CREACIÓN DEL ENEMIGO
# ============================================================

func crear_enemigo_combate() -> Enemy:
	var datos: EnemyData = GameManager.enemy_data_encuentro

	if datos == null:
		push_error("Batalla: no hay un encuentro preparado en GameManager.")
		return null

	if datos.escena_combate == null:
		push_error("Batalla: %s no tiene escena de combate." % datos.nombre)
		return null

	var nuevo_enemigo := datos.escena_combate.instantiate() as Enemy

	if nuevo_enemigo == null:
		push_error("Batalla: la escena no contiene un Enemy válido.")
		return null

	nuevo_enemigo.configurar(datos)

	$CanvasLayer.add_child(nuevo_enemigo)
	nuevo_enemigo.position = Vector2(965, 100)

	return nuevo_enemigo


# ============================================================
# INICIALIZACIÓN
# ============================================================

func _ready() -> void:
	MusicManager.play_battle()

	# --------------------------------------------------------
	# Cargar perfil de éter del Caelius
	# --------------------------------------------------------

	var perfil_eter: EtherProfileData

	match player.tipo_caelius:
		GameManager.TipoCaelius.IRA:
			perfil_eter = load(
				"res://Data/characters/ether_profiles/ether_ira.tres"
			)

		GameManager.TipoCaelius.PENA:
			perfil_eter = load(
				"res://Data/characters/ether_profiles/ether_pena.tres"
			)

		GameManager.TipoCaelius.EGO:
			perfil_eter = load(
				"res://Data/characters/ether_profiles/ether_ego.tres"
			)

	ether_manager.iniciar_combate(perfil_eter)

	# --------------------------------------------------------
	# Crear enemigo
	# --------------------------------------------------------

	enemy = crear_enemigo_combate()

	if enemy == null:
		push_error("Batalla: no se pudo iniciar el combate.")
		return

	# --------------------------------------------------------
	# Conectar DropZone
	# --------------------------------------------------------

	zona_drop.carta_soltada.connect(_on_carta_soltada)

	# --------------------------------------------------------
	# Conectar selección de éteres
	# --------------------------------------------------------

	ether_ui.seleccion_actualizada.connect(
		_on_seleccion_eter_actualizada
	)

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
		ether_manager.iniciar_turno
	)

	combat_manager.turno_enemigo_iniciado.connect(
		ether_manager.finalizar_turno
	)

	combat_manager.turno_enemigo_iniciado.connect(
		_cancelar_pago_pendiente
	)

	combat_manager.turno_jugador_iniciado.connect(
		deck_manager.iniciar_turno
	)

	combat_manager.turno_jugador_iniciado.connect(
		func(): btn_fin_turno.disabled = false
	)

	combat_manager.turno_enemigo_iniciado.connect(
		func(): btn_fin_turno.disabled = true
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

	_actualizar_label_energia(
		player.energia_actual,
		player.energia_max
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

func _on_carta_soltada(
	carta: CardData,
	posicion_global: Vector2) -> void:

	if carta_pendiente != null:
		return

	var objetivo := _resolver_objetivo(
		carta,
		posicion_global
	)

	if objetivo == null:
		return

	intentar_jugar_carta(carta, objetivo)

	# Si quedó pendiente un pago genérico,
	# mantener una representación de la carta visible.
	if carta_pendiente == carta:
		zona_drop.mostrar_carta_pendiente(
			carta,
			posicion_global
		)

# ============================================================
# RESOLUCIÓN DE OBJETIVOS
# ============================================================

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
	candidatos: Array) -> CombatEntity:

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


# ============================================================
# SELECCIÓN DE ÉTERES GENÉRICOS
# ============================================================

func solicitar_pago_eter(
	carta: CardData,
	objetivo: CombatEntity) -> void:

	if carta_pendiente != null:
		return

	if carta.costo_eter == null:
		return

	if not ether_manager.puede_pagar(carta.costo_eter):
		mostrar_aviso("Éteres insuficientes para: " + carta.nombre)
		return

	# Guardar la carta y su objetivo.
	carta_pendiente = carta
	objetivo_pendiente = objetivo

	# Reservar automáticamente los éteres específicos.
	var reservados: Array[int] = (
		ether_manager.obtener_indices_especificos(
			carta.costo_eter
		)
	)

	# Solicitar únicamente los éteres genéricos.
	ether_ui.iniciar_seleccion(
		carta.costo_eter.generico,
		reservados
	)


func _on_seleccion_eter_actualizada(
	indices: Array[int]) -> void:

	if carta_pendiente == null:
		return

	if not ether_ui.seleccion_completa():
		return

	if not combat_manager.es_turno_jugador():
		_cancelar_pago_pendiente()
		return

	var carta: CardData = carta_pendiente
	var objetivo: CombatEntity = objetivo_pendiente

	if not is_instance_valid(objetivo):
		_cancelar_pago_pendiente()
		return

	# --------------------------------------------------------
	# Consumir éteres
	# --------------------------------------------------------

	if not ether_manager.pagar_carta(
		carta.costo_eter,
		indices
	):
		print("No se pudo pagar la carta: ", carta.nombre)
		_cancelar_pago_pendiente()
		return

	# --------------------------------------------------------
	# Limpiar selección
	# --------------------------------------------------------

	_cancelar_pago_pendiente()

	# --------------------------------------------------------
	# Ejecutar carta
	# --------------------------------------------------------

	_ejecutar_carta(carta, objetivo)



func _cancelar_pago_pendiente() -> void:
	carta_pendiente = null
	objetivo_pendiente = null

	zona_drop.ocultar_carta_pendiente()
	ether_ui.cancelar_seleccion()


# ============================================================
# EJECUCIÓN DE CARTAS
# ============================================================

func intentar_jugar_carta(
	carta: CardData,
	objetivo: CombatEntity) -> void:

	if not combat_manager.es_turno_jugador():
		return

	if carta_pendiente != null:
		return

	# --------------------------------------------------------
	# NUEVO SISTEMA DE ÉTERES
	# --------------------------------------------------------

	if carta.costo_eter != null:

		if not ether_manager.puede_pagar(carta.costo_eter):
			mostrar_aviso("Éteres insuficientes para: " + carta.nombre)
			return

		# Cartas que necesitan selección genérica.
		if carta.costo_eter.generico > 0:
			solicitar_pago_eter(carta, objetivo)
			return

		# Cartas con éteres específicos únicamente.
		if not ether_manager.pagar_carta(
			carta.costo_eter,
			[]
		):
			mostrar_aviso("No se pudo pagar la carta: " + carta.nombre)
			return

	# --------------------------------------------------------
	# SISTEMA ANTIGUO DE ENERGÍA
	# --------------------------------------------------------

	else:

		if not player.puede_pagar(carta.costo):
			print("Energía insuficiente para: ", carta.nombre)
			return

		# Evitar usar recuperación de energía si está llena.
		if carta.efectos.size() == 1 and carta.efectos[0] is EnergyEffectData:
			if player.energia_actual >= player.energia_max:
				return

		player.gastar_energia(carta.costo)

	# --------------------------------------------------------
	# EJECUTAR CARTA
	# --------------------------------------------------------

	_ejecutar_carta(carta, objetivo)


func _ejecutar_carta(
	carta: CardData,
	objetivo: CombatEntity) -> void:

	# Aplicar efectos.
	carta.jugar(player, objetivo)

	# Retirar carta de la mano.
	deck_manager.jugar_carta(carta)

	# Animación del jugador.
	if not carta.animacion.is_empty():
		player.reproducir_animacion(carta.animacion)

	# Comprobar victoria o derrota.
	combat_manager.verificar_fin_combate()


# ============================================================
# UI - ENERGÍA ANTIGUA
# ============================================================

func _actualizar_label_energia(
	actual: int,
	maxima: int) -> void:

	for hijo in iconos_energia.get_children():
		iconos_energia.remove_child(hijo)
		hijo.queue_free()

	for i in range(maxima):
		var icono := TextureRect.new()

		icono.texture = ICONO_ENERGIA
		icono.custom_minimum_size = Vector2(45, 45)
		icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		if i >= actual:
			icono.modulate = Color(0.3, 0.3, 0.3, 0.5)
		else:
			icono.modulate = Color("#800020")

		iconos_energia.add_child(icono)


# ============================================================
# EVENTOS DEL COMBATE
# ============================================================

func _on_accion_enemigo_realizada(
	enemigo: Enemy,
	descripcion: String) -> void:
	pass


func _on_combate_terminado(victoria: bool) -> void:

	# Limpiar cualquier selección pendiente.
	_cancelar_pago_pendiente()

	if victoria and GameManager.enemy_data_encuentro != null:
		var zona_id: String = GameManager.zona_id_encuentro
		var enemigo_id: String = GameManager.enemigo_id_encuentro

		if zona_id.is_empty() or enemigo_id.is_empty():
			push_error("Batalla: faltan datos del encuentro.")
			return

		match GameManager.tipo_encuentro:

			GameManager.TipoEncuentro.NORMAL:
				var registrado := GameManager.estado_expedicion.marcar_enemigo_derrotado(
					zona_id,
					enemigo_id
				)

				if not registrado:
					push_error("Batalla: no se pudo registrar al enemigo derrotado.")
					return

				if GameManager.estado_expedicion.todos_enemigos_derrotados(zona_id):
					print("Batalla: zona despejada: ", zona_id)

			GameManager.TipoEncuentro.JEFE:
				GameManager.estado_expedicion.marcar_jefe_derrotado(
					zona_id,
					enemigo_id
				)

				print("Batalla: jefe derrotado: ", enemigo_id)

		GameManager.player_data.hp_actual = player.max_hp
		GameManager.guardar_partida()

		if GameManager.tipo_encuentro == GameManager.TipoEncuentro.JEFE:
			var pantalla_final = SceneManager.add_overlay(
				SceneManager.SceneID.FIN_PARTIDA,
				$CanvasLayer
			)

			if pantalla_final != null:
				pantalla_final.configurar(
					pantalla_final.TipoFinal.CONTINUARA
				)

			return

		SceneManager.change_scene(SceneManager.SceneID.ZONA_ROJA)
		return

	if victoria:
		push_warning("Batalla: victoria sin encuentro de mundo registrado.")
		return

	SceneManager.add_overlay(
		SceneManager.SceneID.FIN_PARTIDA,
		$CanvasLayer
	)


# =============================================================
# AVISOS
# =============================================================
func mostrar_aviso(mensaje: String) -> void:
	if not is_instance_valid(aviso_combate):
		push_warning("BattleScene: falta AvisoCombate.")
		return

	# Cancelar la animación anterior.
	if tween_aviso != null and tween_aviso.is_running():
		tween_aviso.kill()

	aviso_combate.text = mensaje
	aviso_combate.modulate.a = 1.0
	aviso_combate.show()

	# Mostrar el aviso durante 1.5 segundos.
	tween_aviso = create_tween()
	tween_aviso.tween_interval(1.5)

	# Desvanecer suavemente.
	tween_aviso.tween_property(
		aviso_combate,
		"modulate:a",
		0.0,
		0.4
	)

	tween_aviso.tween_callback(aviso_combate.hide)
	
	
# ============================================================
# DEBUG
# ============================================================

func _unhandled_key_input(event: InputEvent) -> void:
	
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE:
				if carta_pendiente != null:
					_cancelar_pago_pendiente()
					get_viewport().set_input_as_handled()
					return
					
	if not OS.is_debug_build():
		return

	if event.is_action_pressed("debug_victoria") and not event.is_echo():
		get_viewport().set_input_as_handled()
		print("DEBUG: victoria forzada")
		_forzar_victoria_debug()

	elif event.is_action_pressed("debug_derrota") and not event.is_echo():
		get_viewport().set_input_as_handled()
		print("DEBUG: derrota forzada")
		_forzar_derrota_debug()


func _forzar_victoria_debug() -> void:
	if combat_manager.estado == CombatManager.Estado.VICTORIA \
	or combat_manager.estado == CombatManager.Estado.DERROTA:
		return

	if not is_instance_valid(enemy):
		push_warning("DEBUG: no hay enemigo válido.")
		return

	enemy.hp = 0
	enemy.actualizar_barra_vida()

	combat_manager.verificar_fin_combate()


func _forzar_derrota_debug() -> void:
	if combat_manager.estado == CombatManager.Estado.VICTORIA \
	or combat_manager.estado == CombatManager.Estado.DERROTA:
		return

	if not is_instance_valid(player):
		push_warning("DEBUG: no hay jugador válido.")
		return

	player.hp = 0
	player.actualizar_barra_vida()

	combat_manager.verificar_fin_combate()
	
	
# ============================================================
# EFECTOS CARTAS
# ============================================================


func _on_mano_carta_seleccionada(carta: CardData) -> void:
	pass # Replace with function body.
