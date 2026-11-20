extends Node2D

# ============================================================
# REFERENCIAS A NODOS
# ============================================================

@onready var combat_manager: CombatManager = $CombatManager
@onready var deck_manager: DeckManager = $DeckManager

@onready var btn_fin_turno: Button = $CanvasLayer/BtnFinTurno
@onready var player: Player = $CanvasLayer/player
@onready var mano_ui: Control = $CanvasLayer/Mano
@onready var zona_drop = $CanvasLayer/DropZone

@onready var ether_manager: EtherManager = $EtherManager
@onready var ether_ui: EtherUI = $CanvasLayer/EtherUI

@onready var aviso_combate: Label = $CanvasLayer/AvisoCombate

@onready var card_effect_resolver: CardEffectResolver = $CardEffectResolver

@onready var label_mazo_robo: Label = $CanvasLayer/UIMazos/MazoRobo/LabelCantidad
@onready var label_mazo_descarte: Label = $CanvasLayer/UIMazos/MazoDescarte/LabelCantidad

@onready var animador_cartas: AnimadorCartas = $CanvasLayer/AnimadorCartas
# ============================================================
# VARIABLES
# ============================================================

var card_play_validator: CardPlayValidator

var enemy: Enemy

var arrastrando_carta: bool = false
var finalizando_turno: bool = false

# Carta pendiente de pago con éteres genéricos.
var carta_pendiente: CardData = null
var carta_ui_pendiente: CardUI = null
var objetivo_pendiente: CombatEntity = null

var tween_aviso: Tween


# ============================================================
# INICIALIZACIÓN
# ============================================================

func _ready() -> void:
	MusicManager.play_battle()

	# Cargar perfil de éter del Caelius.
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

	# Crear enemigo.
	enemy = crear_enemigo_combate()

	if enemy == null:
		push_error("Batalla: no se pudo iniciar el combate.")
		return

	var enemigos: Array[Enemy] = [enemy]

	# Conectar DropZone.
	zona_drop.carta_soltada.connect(_on_carta_soltada)

	# Conectar selección de éteres.
	ether_ui.seleccion_actualizada.connect(
		_on_seleccion_eter_actualizada
	)

	# Configurar mazo.
	deck_manager.iniciar_mazo(
		GameManager.crear_mazo_inicial(player.tipo_caelius)
	)

	# Configurar animador de cartas.
	mano_ui.animador_cartas = animador_cartas
	deck_manager.presentar_robo = _presentar_robo
	deck_manager.presentar_reciclaje = _presentar_reciclaje

	deck_manager.estado_robo_actualizado.connect(
		_on_estado_robo_actualizado)

	deck_manager.cartas_robadas.connect(
		mano_ui.registrar_cartas_robadas
	)

	deck_manager.mano_actualizada.connect(
		mano_ui.mostrar_mano
	)

	deck_manager.mano_actualizada.connect(
	func(_cartas: Array[CardData]) -> void:
		_actualizar_contadores_mazos()
	)

	# Configurar resolver y validador.
	card_effect_resolver.configurar(deck_manager)
	card_effect_resolver.contexto.configurar_mano(mano_ui)
	card_effect_resolver.contexto.animador_cartas = animador_cartas

	card_play_validator = CardPlayValidator.new(
		deck_manager,
		ether_manager,
		combat_manager,
		player,
		card_effect_resolver)

	mano_ui.card_play_validator = card_play_validator

	card_effect_resolver.carta_finalizada.connect(
		_on_carta_finalizada
	)

	# Actualización visual por cambios de éteres.
	ether_manager.eteres_actualizados.connect(
		mano_ui.actualizar_disponibilidad_todas
	)

	# Eventos del turno del jugador.
	combat_manager.turno_jugador_iniciado.connect(
		ether_manager.iniciar_turno
	)

	combat_manager.turno_jugador_iniciado.connect(
		deck_manager.iniciar_turno
	)

	combat_manager.turno_jugador_iniciado.connect(
		mano_ui.actualizar_disponibilidad_todas
	)

	combat_manager.turno_jugador_iniciado.connect(
		func(): _actualizar_estado_boton_fin_turno()
	)

	# Eventos del turno enemigo.
	combat_manager.turno_enemigo_iniciado.connect(
		ether_manager.finalizar_turno
	)

	combat_manager.turno_enemigo_iniciado.connect(
		mano_ui.actualizar_disponibilidad_todas
	)

	combat_manager.turno_enemigo_iniciado.connect(
		_cancelar_pago_pendiente
	)

	combat_manager.turno_enemigo_iniciado.connect(
		func(): btn_fin_turno.disabled = true
	)

	# Eventos del combate.
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

	# Botón finalizar turno.
	btn_fin_turno.pressed.connect(
		_on_fin_turno_presionado
	)

	# Iniciar combate.
	combat_manager.iniciar_combate(
		player,
		enemigos
	)

	mano_ui.actualizar_disponibilidad_todas()


# ============================================================
# CREACIÓN DEL ENEMIGO
# ============================================================

func crear_enemigo_combate() -> Enemy:
	var datos: EnemyData = GameManager.enemy_data_encuentro

	if datos == null:
		push_error("Batalla: no hay un encuentro preparado en GameManager.")
		return null

	if datos.escena_combate == null:
		push_error(
			"Batalla: %s no tiene escena de combate." % datos.nombre
		)
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
# PROCESAMIENTO DEL ARRASTRE
# ============================================================

func _process(_delta: float) -> void:
	var drag_data = get_viewport().gui_get_drag_data()

	if drag_data is CardUI and is_instance_valid(drag_data):
		if not arrastrando_carta:
			arrastrando_carta = true
			_actualizar_gris_por_carta(drag_data.carta)
	else:
		if arrastrando_carta:
			arrastrando_carta = false
			_resetear_gris()


# ============================================================
# INDICADOR VISUAL DE OBJETIVOS
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
	if is_instance_valid(player):
		_set_gris(player, false)

	if is_instance_valid(enemy):
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
# SOLTAR CARTAS
# ============================================================

func _on_carta_soltada(
	card_ui: CardUI,
	posicion_global: Vector2) -> void:

	if finalizando_turno:
		return

	if deck_manager.robando:
		return

	if card_effect_resolver.ejecutando:
		return

	if carta_pendiente != null:
		return

	if not is_instance_valid(card_ui):
		return

	var carta: CardData = card_ui.carta

	if not _carta_ui_valida(card_ui, carta):
		return

	var objetivo := _resolver_objetivo(
		carta,
		posicion_global
	)

	if objetivo == null:
		return

	# Guardar la posición antes de ejecutar la carta.
	card_ui.set_meta("posicion_soltada", posicion_global)

	intentar_jugar_carta(carta, objetivo, card_ui)

	# Mantener visible la carta durante el pago genérico.
	if carta_ui_pendiente == card_ui:
		zona_drop.mostrar_carta_pendiente(
			carta,
			posicion_global
		)

# ============================================================
# RESOLUCIÓN DE OBJETIVOS
# ============================================================

func _resolver_objetivo(
	carta: CardData,
	posicion_global: Vector2) -> CombatEntity:

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
	var mejor_dist: float = INF

	for candidato in candidatos:
		if not is_instance_valid(candidato):
			continue

		var distancia: float = candidato.global_position.distance_to(
			posicion_global
		)

		if distancia < mejor_dist:
			mejor_dist = distancia
			mejor = candidato

	return mejor


# ============================================================
# PAGO DE ÉTERES GENÉRICOS
# ============================================================

func solicitar_pago_eter(
	carta: CardData,
	objetivo: CombatEntity,
	card_ui: CardUI) -> void:

	if carta_pendiente != null:
		return

	if not _carta_ui_valida(card_ui, carta):
		return

	if carta.costo_eter == null:
		return

	if not ether_manager.puede_pagar(carta.costo_eter):
		mostrar_aviso(
			"Éteres insuficientes para: " + carta.nombre
		)
		return

	carta_pendiente = carta
	carta_ui_pendiente = card_ui
	objetivo_pendiente = objetivo
	btn_fin_turno.disabled = true

	var reservados: Array[int] = (
		ether_manager.obtener_indices_especificos(
			carta.costo_eter
		)
	)

	ether_ui.iniciar_seleccion(
		carta.costo_eter.generico,
		reservados
	)

	mano_ui.actualizar_disponibilidad_todas()

func _on_seleccion_eter_actualizada(indices: Array[int]) -> void:
	if finalizando_turno:
		return

	if card_effect_resolver.ejecutando:
		return

	if carta_pendiente == null:
		return

	if not ether_ui.seleccion_completa():
		return

	if not combat_manager.es_turno_jugador():
		_cancelar_pago_pendiente()
		return

	var carta: CardData = carta_pendiente
	var card_ui: CardUI = carta_ui_pendiente
	var objetivo: CombatEntity = objetivo_pendiente

	if not _carta_ui_valida(card_ui, carta):
		_cancelar_pago_pendiente()
		return

	if not is_instance_valid(objetivo):
		_cancelar_pago_pendiente()
		return

	if not card_play_validator.puede_jugar(carta):
		mostrar_aviso(
			card_play_validator.motivo_no_jugable
		)
		_cancelar_pago_pendiente()
		return

	if not ether_manager.pagar_carta(
		carta.costo_eter,
		indices
	):
		mostrar_aviso(
			"No se pudo pagar: " + carta.nombre
		)
		_cancelar_pago_pendiente()
		return

	_cancelar_pago_pendiente()
	_ejecutar_carta(carta, objetivo, card_ui)


func _cancelar_pago_pendiente() -> void:
	carta_pendiente = null
	carta_ui_pendiente = null
	objetivo_pendiente = null

	zona_drop.ocultar_carta_pendiente()
	ether_ui.cancelar_seleccion()

	if card_play_validator != null:
		mano_ui.actualizar_disponibilidad_todas()

	_actualizar_estado_boton_fin_turno()
# ============================================================
# VALIDACIÓN Y EJECUCIÓN DE CARTAS
# ============================================================

func intentar_jugar_carta(
	carta: CardData,
	objetivo: CombatEntity,
	card_ui: CardUI) -> void:

	if finalizando_turno:
		return

	if deck_manager.robando:
		return

	if not _carta_ui_valida(card_ui, carta):
		return

	if not card_play_validator.puede_jugar(
		carta,
		carta_pendiente != null
	):
		mostrar_aviso(
			card_play_validator.motivo_no_jugable
		)
		return

	if carta.costo_eter == null:
		push_error(
			"La carta no tiene costo_eter: " + carta.nombre
		)
		return

	# Solicitar selección de éteres genéricos.
	if carta.costo_eter.generico > 0:
		solicitar_pago_eter(carta, objetivo, card_ui)
		return

	# Pagar éteres específicos.
	if not ether_manager.pagar_carta(
		carta.costo_eter,
		[]
	):
		mostrar_aviso(
			"No se pudo pagar: " + carta.nombre
		)
		return

	_ejecutar_carta(carta, objetivo, card_ui)


func _ejecutar_carta(
	carta: CardData,
	objetivo: CombatEntity,
	card_ui: CardUI) -> void:

	if card_effect_resolver.ejecutando:
		return

	if not _carta_ui_valida(card_ui, carta):
		return

	var indice: int = mano_ui.obtener_indice_carta(card_ui)

	# Capturar la información visual antes de retirar la carta.
	var centro_original: Vector2 = (
		card_ui.get_global_transform()
		* (card_ui.size / 2.0)
	)

	var origen_descarte: Vector2 = card_ui.get_meta(
		"posicion_soltada", centro_original)

	var tamano_carta: Vector2 = card_ui.size

	btn_fin_turno.disabled = true

	# Retirar la copia exacta de la mano.
	if not deck_manager.jugar_carta(indice, carta):
		_actualizar_estado_boton_fin_turno()
		return

	# Animar el descarte desde donde se soltó la carta.
	if is_instance_valid(animador_cartas):
		animador_cartas.animar_descarte(
			carta,
			origen_descarte,
			tamano_carta
		)

	# Reproducir animación del personaje.
	if not carta.animacion.is_empty():
		player.reproducir_animacion(carta.animacion)

	# Ejecutar efectos.
	card_effect_resolver.ejecutar_carta(
		carta,
		player,
		objetivo
	)

	mano_ui.actualizar_disponibilidad_todas()


func _on_carta_finalizada(_carta: CardData) -> void:
	if combat_manager.verificar_fin_combate():
		return

	# Esperar al final del ciclo actual por si el resolver aún está finalizando.
	call_deferred("_actualizar_estado_boton_fin_turno")
	mano_ui.actualizar_disponibilidad_todas()


func _carta_ui_valida(
	card_ui: CardUI,
	carta: CardData) -> bool:

	if not is_instance_valid(card_ui):
		return false

	if card_ui.is_queued_for_deletion():
		return false

	if card_ui.get_parent() != mano_ui:
		return false

	if carta == null or card_ui.carta != carta:
		return false

	var indice: int = mano_ui.obtener_indice_carta(card_ui)

	return deck_manager.es_carta_en_indice(
		indice,
		carta
	)
# ============================================================
# EVENTOS DEL COMBATE
# ============================================================

func _on_accion_enemigo_realizada(
	_enemigo: Enemy,
	_descripcion: String) -> void:
	pass


func _on_combate_terminado(victoria: bool) -> void:
	deck_manager.cancelar_robo()

	btn_fin_turno.disabled = true
	_cancelar_pago_pendiente()

	card_effect_resolver.cancelar_ejecucion()

	mano_ui.cerrar_mano()
	if is_instance_valid(animador_cartas):
		animador_cartas.cancelar_animaciones_descarte()
		animador_cartas.cancelar_animaciones_reciclaje()

	if victoria and GameManager.enemy_data_encuentro != null:
		var zona_id: String = GameManager.zona_id_encuentro
		var enemigo_id: String = GameManager.enemigo_id_encuentro

		if zona_id.is_empty() or enemigo_id.is_empty():
			push_error(
				"Batalla: faltan datos del encuentro."
			)
			return

		match GameManager.tipo_encuentro:
			GameManager.TipoEncuentro.NORMAL:
				var registrado := (
					GameManager.estado_expedicion.marcar_enemigo_derrotado(
						zona_id,
						enemigo_id
					)
				)

				if not registrado:
					push_error(
						"Batalla: no se pudo registrar al enemigo derrotado."
					)
					return

				if GameManager.estado_expedicion.todos_enemigos_derrotados(
					zona_id
				):
					print(
						"Batalla: zona despejada: ",
						zona_id
					)

			GameManager.TipoEncuentro.JEFE:
				GameManager.estado_expedicion.marcar_jefe_derrotado(
					zona_id,
					enemigo_id
				)

				print(
					"Batalla: jefe derrotado: ",
					enemigo_id
				)

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

		SceneManager.change_scene(
			SceneManager.SceneID.ZONA_ROJA
		)
		return

	if victoria:
		push_warning(
			"Batalla: victoria sin encuentro de mundo registrado."
		)
		return

	SceneManager.add_overlay(
		SceneManager.SceneID.FIN_PARTIDA,
		$CanvasLayer
	)

func _exit_tree() -> void:
	if is_instance_valid(deck_manager):
		deck_manager.cancelar_robo()

	if is_instance_valid(animador_cartas):
		animador_cartas.cancelar_animaciones_reciclaje()

	if card_effect_resolver != null:
		card_effect_resolver.cancelar_ejecucion()

# ============================================================
# AVISOS
# ============================================================

func mostrar_aviso(mensaje: String) -> void:
	if not is_instance_valid(aviso_combate):
		push_warning(
			"BattleScene: falta AvisoCombate."
		)
		return

	if tween_aviso != null and tween_aviso.is_running():
		tween_aviso.kill()

	aviso_combate.text = mensaje
	aviso_combate.modulate.a = 1.0
	aviso_combate.show()

	tween_aviso = create_tween()
	tween_aviso.tween_interval(1.5)

	tween_aviso.tween_property(
		aviso_combate,
		"modulate:a",
		0.0,
		0.4
	)

	tween_aviso.tween_callback(
		aviso_combate.hide
	)


func _actualizar_contadores_mazos() -> void:
	label_mazo_robo.text = str(deck_manager.mazo_robo.size())
	label_mazo_descarte.text = str(deck_manager.mazo_descarte.size())


# ============================================================
# COORDINACIÓN DE ROBO Y RECICLAJE
# ============================================================

func _presentar_robo() -> void:
	if not is_instance_valid(mano_ui):
		return

	await mano_ui.esperar_presentacion_robo()


func _presentar_reciclaje(cantidad: int) -> void:
	if deck_manager.robo_cancelado:
		return

	if is_instance_valid(animador_cartas):
		animador_cartas.animar_reciclaje(cantidad)
		await animador_cartas.esperar_reciclaje()

	if deck_manager.robo_cancelado or not is_inside_tree():
		return

	_actualizar_contadores_mazos()

	if is_instance_valid(animador_cartas):
		var pausa: float = animador_cartas.pausa_reciclaje_robo

		if pausa > 0.0:
			await get_tree().create_timer(pausa).timeout


func _on_estado_robo_actualizado(robando: bool) -> void:
	if is_instance_valid(mano_ui):
		mano_ui.bloquear_robo(robando)

	_actualizar_estado_boton_fin_turno()

	if not robando and not deck_manager.robo_cancelado:
		mano_ui.actualizar_disponibilidad_todas()


func _actualizar_estado_boton_fin_turno() -> void:
	btn_fin_turno.disabled = (
		deck_manager.robando
		or deck_manager.robo_cancelado
		or finalizando_turno
		or carta_pendiente != null
		or card_effect_resolver.ejecutando
		or not combat_manager.es_turno_jugador()
	)


# ============================================================
# FINALIZACIÓN DEL TURNO
# ============================================================

func _on_fin_turno_presionado() -> void:
	if finalizando_turno:
		return

	if deck_manager.robando or deck_manager.robo_cancelado:
		return

	if not combat_manager.es_turno_jugador():
		return

	if card_effect_resolver.ejecutando:
		return

	if carta_pendiente != null:
		return

	# Bloquear nuevas acciones.
	finalizando_turno = true
	btn_fin_turno.disabled = true

	# Finalizar animaciones de robo pendientes.
	mano_ui.finalizar_animaciones_robo()

	# Animar y descartar las cartas restantes.
	_descartar_mano_completa()

	# Esperar todos los descartes activos.
	if is_instance_valid(animador_cartas):
		await animador_cartas.esperar_descartes()

	# Comprobar que la batalla siga activa.
	if not is_inside_tree():
		return

	finalizando_turno = false

	if combat_manager.verificar_fin_combate():
		return

	if not combat_manager.es_turno_jugador():
		return

	# Iniciar el turno enemigo.
	combat_manager.finalizar_turno_jugador()



func _descartar_mano_completa() -> void:
	var cartas_visuales: Array[CardUI] = (
		mano_ui.obtener_cartas_visuales())

	# Crear las animaciones de descarte.
	if is_instance_valid(animador_cartas):
		for card_ui in cartas_visuales:
			if not is_instance_valid(card_ui):
				continue

			if card_ui.carta == null:
				continue

			var centro_global: Vector2 = (
				card_ui.get_global_transform()
				* (card_ui.size / 2.0))

			animador_cartas.animar_descarte(
				card_ui.carta,
				centro_global,
				card_ui.size,
				card_ui.rotation_degrees,
				card_ui.scale
			)

	# Vaciar la mano lógica y actualizar la interfaz.
	deck_manager.descartar_mano()
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

	if event.is_action_pressed(
		"debug_victoria"
	) and not event.is_echo():
		get_viewport().set_input_as_handled()
		print("DEBUG: victoria forzada")
		_forzar_victoria_debug()

	elif event.is_action_pressed(
		"debug_derrota"
	) and not event.is_echo():
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
