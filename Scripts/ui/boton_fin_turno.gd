class_name BotonFinTurno
extends Button

# ============================================================
# CONFIGURACIÓN VISUAL
# ============================================================

@export_group("Resaltado")
@export var color_resaltado: Color = Color("#F4CE42")
@export_range(1, 8, 1) var grosor_borde: int = 3
@export_range(0, 24, 1) var radio_esquinas: int = 8

@export_group("Parpadeo")
@export_range(0.1, 1.0, 0.05) var opacidad_minima: float = 0.25
@export_range(0.1, 2.0, 0.05) var duracion_fase: float = 0.5

# ============================================================
# REFERENCIAS
# ============================================================

var deck_manager: DeckManager
var ether_manager: EtherManager
var combat_manager: CombatManager
var card_play_validator: CardPlayValidator

var borde_resaltado: Panel
var tween_parpadeo: Tween


# ============================================================
# INICIALIZACIÓN
# ============================================================

func _ready() -> void:
	_crear_borde_resaltado()


func _exit_tree() -> void:
	_detener_parpadeo()


func configurar(
	p_deck_manager: DeckManager,
	p_ether_manager: EtherManager,
	p_combat_manager: CombatManager,
	p_card_play_validator: CardPlayValidator) -> void:

	deck_manager = p_deck_manager
	ether_manager = p_ether_manager
	combat_manager = p_combat_manager
	card_play_validator = p_card_play_validator

	if not deck_manager.mano_actualizada.is_connected(_on_mano_actualizada):
		deck_manager.mano_actualizada.connect(_on_mano_actualizada)

	if not ether_manager.eteres_actualizados.is_connected(actualizar_resaltado):
		ether_manager.eteres_actualizados.connect(actualizar_resaltado)

	actualizar_resaltado()


# ============================================================
# ESTADO DEL BOTÓN
# ============================================================

func establecer_habilitado(habilitado: bool) -> void:
	disabled = not habilitado
	actualizar_resaltado()


func actualizar_resaltado() -> void:
	if not is_instance_valid(borde_resaltado):
		return

	if disabled or not _referencias_validas():
		_establecer_resaltado(false)
		return

	if not combat_manager.es_turno_jugador():
		_establecer_resaltado(false)
		return

	var sin_cartas: bool = deck_manager.mano.is_empty()
	var sin_eteres: bool = _sin_eteres_disponibles()
	var sin_jugadas: bool = false

	if not sin_cartas and not sin_eteres:
		sin_jugadas = not _hay_cartas_jugables()

	_establecer_resaltado(sin_cartas or sin_eteres or sin_jugadas)


func _referencias_validas() -> bool:
	return (
		is_instance_valid(deck_manager)
		and is_instance_valid(ether_manager)
		and is_instance_valid(combat_manager)
		and card_play_validator != null
	)


func _sin_eteres_disponibles() -> bool:
	for eter in ether_manager.eteres:
		if eter != EtherManager.ETER_VACIO:
			return false

	return true


func _hay_cartas_jugables() -> bool:
	for carta in deck_manager.mano:
		if card_play_validator.puede_jugar(carta):
			return true

	return false


func _on_mano_actualizada(_cartas: Array[CardData]) -> void:
	actualizar_resaltado()


# ============================================================
# PRESENTACIÓN
# ============================================================

func _crear_borde_resaltado() -> void:
	borde_resaltado = Panel.new()
	borde_resaltado.name = "BordeResaltado"
	borde_resaltado.mouse_filter = Control.MOUSE_FILTER_IGNORE
	borde_resaltado.focus_mode = Control.FOCUS_NONE

	var estilo := StyleBoxFlat.new()
	estilo.draw_center = false
	estilo.set_border_width_all(grosor_borde)
	estilo.border_color = color_resaltado
	estilo.set_corner_radius_all(radio_esquinas)

	borde_resaltado.add_theme_stylebox_override("panel", estilo)
	add_child(borde_resaltado)
	borde_resaltado.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	borde_resaltado.hide()


func _establecer_resaltado(mostrar: bool) -> void:
	if not mostrar:
		_detener_parpadeo()
		borde_resaltado.hide()
		return

	# Si ya está parpadeando, no reiniciar el tween al recibir señales.
	if borde_resaltado.visible and tween_parpadeo != null and tween_parpadeo.is_running():
		return

	borde_resaltado.show()
	borde_resaltado.modulate = Color.WHITE
	_detener_parpadeo()

	tween_parpadeo = create_tween()
	tween_parpadeo.set_loops()
	tween_parpadeo.tween_property(
		borde_resaltado, "modulate:a", opacidad_minima, duracion_fase
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_parpadeo.tween_property(
		borde_resaltado, "modulate:a", 1.0, duracion_fase
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _detener_parpadeo() -> void:
	if tween_parpadeo != null and tween_parpadeo.is_valid():
		tween_parpadeo.kill()

	tween_parpadeo = null

	if is_instance_valid(borde_resaltado):
		borde_resaltado.modulate = Color.WHITE
