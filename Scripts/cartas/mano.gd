extends Control

const CARD_UI_SCENE := preload("res://Scenes/ui/card_ui.tscn")

const COLOR_SELECCION := Color("b29500ff")
const COLOR_NO_JUGABLE := Color(0.45, 0.45, 0.45, 1.0)
const Z_INDEX_ELEVADO := 100

enum ModoInteraccion {
	NORMAL,
	SELECCIONAR_DESCARTE
}

signal carta_seleccionada(carta: CardData)
signal seleccion_descarte_resuelta(card_ui: CardUI)
signal carta_descarte_marcada(carta: CardData)


# ============================================================
# CONFIGURACIÓN
# ============================================================

@export_group("Distribución de cartas")
@export var ancho_carta: float = 140.0
@export var alto_carta: float = 200.0
@export var separacion: float = 100.0
@export var altura_arco: float = 35.0
@export var rotacion_maxima: float = 10.0

@export_group("Interacción")
@export var elevacion_hover: float = 50.0
@export var duracion_hover: float = 0.15
@export_range(0.0, 40.0, 1.0) var margen_hover: float = 15.0

@export_group("Tooltip")
@export var retraso_tooltip: float = 0.4

# ============================================================
# REFERENCIAS
# ============================================================

@onready var tooltip: CardTooltip = get_node_or_null("../CardTooltip") as CardTooltip

@onready var ui_seleccion_descarte: Control = (
	get_node_or_null("../UISeleccionDescarte") as Control
)

@onready var label_instruccion: Label = (
	get_node_or_null("../UISeleccionDescarte/LabelInstruccion") as Label
)

@onready var btn_confirmar_descarte: Button = (
	get_node_or_null("../UISeleccionDescarte/BtnConfirmarDescarte") as Button
)


# ============================================================
# ESTADO
# ============================================================

var card_play_validator: CardPlayValidator

var modo_actual: ModoInteraccion = ModoInteraccion.NORMAL

var carta_hover: CardUI = null
var carta_ui_marcada: CardUI = null

var seleccion_descarte_realizada: bool = false

var tiempo_hover: float = 0.0
var tooltip_visible: bool = false

var posiciones_originales: Dictionary = {}
var rotaciones_originales: Dictionary = {}
var indices_originales: Dictionary = {}

var tweens_cartas: Dictionary = {}

# Evita distribuir una reconstrucción anterior.
var version_mano: int = 0

var cantidad_robadas_pendientes: int = 0
var mano_cerrada: bool = false

var animador_cartas: AnimadorCartas

# ============================================================
# INICIALIZACIÓN
# ============================================================

func _ready() -> void:
	if not is_instance_valid(tooltip):
		push_warning("Mano: falta CardTooltip; se omitirán los tooltips.")
	if not _ui_descarte_valida():
		push_error("Mano: faltan nodos de UISeleccionDescarte.")
		return
	btn_confirmar_descarte.pressed.connect(confirmar_descarte)

	if _ui_descarte_valida():
		ui_seleccion_descarte.hide()
		btn_confirmar_descarte.disabled = true


# ============================================================
# DETECCIÓN DE HOVER
# ============================================================

func _process(delta: float) -> void:
	if mano_cerrada or not is_visible_in_tree():
		return
	if posiciones_originales.is_empty():
		return

	var nueva_carta: CardUI = _detectar_carta_hover()

	if nueva_carta != carta_hover:
		_cambiar_hover(nueva_carta)

	if carta_hover == null:
		return

	tiempo_hover += delta

	if tiempo_hover >= retraso_tooltip and not tooltip_visible:
		_mostrar_tooltip()


func _detectar_carta_hover() -> CardUI:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var cartas := get_children()

	for i in range(cartas.size() - 1, -1, -1):
		var card_ui := cartas[i] as CardUI

		if card_ui == null or not card_ui.is_visible_in_tree():
			continue

		if _esta_animando_robo(card_ui):
			continue

		if not posiciones_originales.has(card_ui):
			continue

		var posicion_original: Vector2 = (
			posiciones_originales[card_ui]
		)

		var posicion_global: Vector2 = (
			get_global_transform() * posicion_original
		)

		var rect := Rect2(
			posicion_global + Vector2(margen_hover, margen_hover),
			Vector2(
				ancho_carta - margen_hover * 2.0,
				alto_carta - margen_hover * 2.0
			)
		)

		if rect.has_point(mouse_pos):
			return card_ui

	return null


func _cambiar_hover(nueva_carta: CardUI) -> void:
	var carta_anterior: CardUI = carta_hover

	_ocultar_tooltip()

	carta_hover = nueva_carta

	_actualizar_estado_visual_carta(carta_anterior)
	_actualizar_estado_visual_carta(carta_hover)


# ============================================================
# ESTADO VISUAL Y ANIMACIONES
# ============================================================

func _es_carta_marcada(card_ui: CardUI) -> bool:
	return (
		modo_actual == ModoInteraccion.SELECCIONAR_DESCARTE
		and is_instance_valid(carta_ui_marcada)
		and card_ui == carta_ui_marcada
	)

func _esta_animando_robo(card_ui: CardUI) -> bool:
	if not is_instance_valid(animador_cartas):
		return false

	return animador_cartas.esta_animando_robo(card_ui)
	

func _actualizar_estado_visual_carta(card_ui: CardUI) -> void:
	if not is_instance_valid(card_ui):
		return

	if _esta_animando_robo(card_ui):
		return

	if (
		not posiciones_originales.has(card_ui)
		or not rotaciones_originales.has(card_ui)
		or not indices_originales.has(card_ui)
	):
		return

	var elevada: bool = (
		card_ui == carta_hover
		or _es_carta_marcada(card_ui))

	var posicion: Vector2 = posiciones_originales[card_ui]
	var rotacion: float = rotaciones_originales[card_ui]
	var indice: int = indices_originales[card_ui]

	if elevada:
		posicion -= Vector2(0, elevacion_hover)
		rotacion = 0.0
		indice = Z_INDEX_ELEVADO

	_animar_carta(card_ui, posicion, rotacion, indice)


func _actualizar_estado_visual_todas() -> void:
	for hijo in get_children():
		if hijo is CardUI:
			_actualizar_estado_visual_carta(hijo)


func _animar_carta(
	carta: CardUI,
	destino: Vector2,
	rotacion: float,
	indice: int) -> void:
	if tweens_cartas.has(carta):
		var tween_anterior: Tween = tweens_cartas[carta]

		if tween_anterior != null and tween_anterior.is_valid():
			tween_anterior.kill()

	carta.z_index = indice

	# Evitar crear un tween si ya está en su destino.
	if (
		carta.position.is_equal_approx(destino)
		and is_equal_approx(carta.rotation_degrees, rotacion)
	):
		return

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		carta,
		"position",
		destino,
		duracion_hover
	)

	tween.tween_property(
		carta,
		"rotation_degrees",
		rotacion,
		duracion_hover
	)

	tweens_cartas[carta] = tween


func _animar_entrada_carta(card_ui: CardUI) -> void:
	if not is_instance_valid(animador_cartas):
		return

	if not is_instance_valid(card_ui):
		return

	if not posiciones_originales.has(card_ui) or not rotaciones_originales.has(card_ui):
		push_warning("Mano: carta sin distribución registrada.")
		return

	var destino: Vector2 = posiciones_originales[card_ui]
	var rotacion_final: float = rotaciones_originales[card_ui]

	var tween: Tween = animador_cartas.animar_robo(
		card_ui,
		destino,
		rotacion_final
	)

	if tween == null:
		return

	card_ui.permitir_arrastre = false

	tween.finished.connect(
		func():
			if is_instance_valid(card_ui) and not mano_cerrada:
				_actualizar_interaccion_cartas()
				_actualizar_estado_visual_carta(card_ui)
	)
# ============================================================
# CONSTRUCCIÓN DE LA MANO
# ============================================================

func mostrar_mano(cartas: Array[CardData]) -> void:
	if mano_cerrada:
		return
	version_mano += 1
	var version_actual: int = version_mano

	var cantidad_nuevas: int = mini(
		cantidad_robadas_pendientes,
		cartas.size()
	)

	cantidad_robadas_pendientes = 0

	var primer_indice_nuevo: int = (
		cartas.size() - cantidad_nuevas
	)

	_limpiar_cartas_visuales()

	for i in range(cartas.size()):
		var carta: CardData = cartas[i]
		if carta == null:
			push_warning("Mano: se recibió una carta nula; se omite.")
			continue
		var instancia := CARD_UI_SCENE.instantiate()
		var card_ui := instancia as CardUI
		if card_ui == null:
			instancia.free()
			push_error("Mano: card_ui.tscn no tiene una raíz CardUI.")
			break
		card_ui.set_meta("robo_nuevo", i >= primer_indice_nuevo)
		card_ui.set_meta("indice_mano", i)

		card_ui.hide()
		add_child(card_ui)

		card_ui.carta_clickeada.connect(
			_on_carta_clickeada.bind(card_ui)
		)

		card_ui.permitir_arrastre = (
			modo_actual == ModoInteraccion.NORMAL
		)

		card_ui.custom_minimum_size = Vector2(
			ancho_carta,
			alto_carta
		)

		card_ui.size = Vector2(ancho_carta, alto_carta)

		card_ui.setear_carta(carta)

		_actualizar_disponibilidad(card_ui)

	await get_tree().process_frame

	if not is_inside_tree():
		return

	if version_actual != version_mano:
		return

	if not is_visible_in_tree():
		return

	_distribuir_cartas()

	var cartas_visuales := obtener_cartas_visuales()

	for i in range(cartas_visuales.size()):
		var card_ui: CardUI = cartas_visuales[i]

		if (
			bool(card_ui.get_meta("robo_nuevo", false))
			and modo_actual == ModoInteraccion.NORMAL
		):
			_animar_entrada_carta(card_ui)

		card_ui.remove_meta("robo_nuevo")
		card_ui.show()


func _limpiar_cartas_visuales() -> void:
	finalizar_animaciones_robo()
	_ocultar_tooltip()

	carta_hover = null
	carta_ui_marcada = null

	if is_instance_valid(btn_confirmar_descarte):
		btn_confirmar_descarte.disabled = true

	for tween in tweens_cartas.values():
		if tween != null and tween.is_valid():
			tween.kill()

	tweens_cartas.clear()

	posiciones_originales.clear()
	rotaciones_originales.clear()
	indices_originales.clear()

	for hijo in get_children():
		if hijo is CardUI:
			remove_child(hijo)
			hijo.queue_free()
					
			
func registrar_cartas_robadas(cartas: Array[CardData]) -> void:
	cantidad_robadas_pendientes = cartas.size()

# ============================================================
# DISTRIBUCIÓN DE CARTAS
# ============================================================

func _distribuir_cartas() -> void:
	var cartas: Array[CardUI] = obtener_cartas_visuales()
	posiciones_originales.clear()
	rotaciones_originales.clear()
	indices_originales.clear()

	var cantidad: int = cartas.size()
	if cantidad == 0:
		return

	var ancho_total: float = ancho_carta + (cantidad - 1) * separacion
	var inicio_x: float = (size.x - ancho_total) / 2.0
	var base_y: float = size.y - alto_carta - 35.0

	for i in range(cantidad):
		var card_ui: CardUI = cartas[i]
		var t: float = 0.0
		if cantidad > 1:
			t = (float(i) - float(cantidad - 1) / 2.0) / (float(cantidad - 1) / 2.0)

		card_ui.pivot_offset = Vector2(ancho_carta / 2.0, alto_carta)
		card_ui.position = Vector2(inicio_x + i * separacion, base_y + t * t * altura_arco)
		card_ui.rotation_degrees = t * rotacion_maxima
		card_ui.z_index = cantidad - absi(i - int(cantidad / 2.0))

		posiciones_originales[card_ui] = card_ui.position
		rotaciones_originales[card_ui] = card_ui.rotation_degrees
		indices_originales[card_ui] = card_ui.z_index

	_actualizar_estado_visual_todas()


func obtener_cartas_visuales() -> Array[CardUI]:
	var cartas: Array[CardUI] = []

	for hijo in get_children():
		if hijo is CardUI:
			cartas.append(hijo)

	return cartas


func obtener_indice_carta(card_ui: CardUI) -> int:
	if not is_instance_valid(card_ui):
		return -1

	if card_ui.is_queued_for_deletion():
		return -1

	if card_ui.get_parent() != self:
		return -1

	return int(card_ui.get_meta("indice_mano", -1))
# ============================================================
# DISPONIBILIDAD Y COLORES
# ============================================================

func actualizar_disponibilidad_todas() -> void:
	for hijo in get_children():
		if hijo is CardUI:
			_actualizar_disponibilidad(hijo)


func _actualizar_disponibilidad(card_ui: CardUI) -> void:
	if card_ui.carta == null:
		return

	# La carta marcada tiene prioridad visual.
	if _es_carta_marcada(card_ui):
		card_ui.modulate = COLOR_SELECCION
		return

	# Durante el descarte, todas son seleccionables.
	if modo_actual == ModoInteraccion.SELECCIONAR_DESCARTE:
		card_ui.modulate = Color.WHITE
		return

	if card_play_validator == null:
		card_ui.modulate = Color.WHITE
		return

	if card_play_validator.puede_jugar(card_ui.carta):
		card_ui.modulate = Color.WHITE
	else:
		card_ui.modulate = COLOR_NO_JUGABLE


# ============================================================
# TOOLTIP
# ============================================================

func _ocultar_tooltip() -> void:
	tiempo_hover = 0.0
	tooltip_visible = false
	if is_instance_valid(tooltip):
		tooltip.ocultar()


func _mostrar_tooltip() -> void:
	if not is_instance_valid(tooltip):
		return
	if not is_instance_valid(carta_hover):
		return

	if carta_hover.carta == null:
		return

	tooltip.mostrar_carta(carta_hover.carta)

	var posicion: Vector2 = carta_hover.global_position

	posicion.x += (
		carta_hover.size.x - tooltip.size.x
	) / 2.0

	posicion.y -= tooltip.size.y + 8.0

	var pantalla: Vector2 = get_viewport_rect().size

	posicion.x = clampf(
		posicion.x,
		0.0,
		maxf(0.0, pantalla.x - tooltip.size.x)
	)

	posicion.y = maxf(0.0, posicion.y)

	tooltip.global_position = posicion
	tooltip_visible = true


# ============================================================
# SELECCIÓN DE DESCARTE
# ============================================================

func iniciar_seleccion_descarte() -> void:
	if mano_cerrada or not _ui_descarte_valida():
		call_deferred("_notificar_descarte_no_disponible")
		return
	finalizar_animaciones_robo()
	modo_actual = ModoInteraccion.SELECCIONAR_DESCARTE

	seleccion_descarte_realizada = false
	carta_ui_marcada = null

	label_instruccion.text = (
		"Seleccioná una carta para descartar"
	)

	btn_confirmar_descarte.disabled = true
	ui_seleccion_descarte.show()

	_actualizar_interaccion_cartas()
	actualizar_disponibilidad_todas()
	_actualizar_estado_visual_todas()


func _on_carta_clickeada(
	carta: CardData,
	card_ui: CardUI) -> void:
	if modo_actual != ModoInteraccion.SELECCIONAR_DESCARTE:
		return

	if seleccion_descarte_realizada:
		return

	if carta == null or not is_instance_valid(card_ui):
		return

	if card_ui.get_parent() != self:
		return

	if _esta_animando_robo(card_ui):
		return

	carta_ui_marcada = card_ui

	btn_confirmar_descarte.disabled = false

	actualizar_disponibilidad_todas()
	_actualizar_estado_visual_todas()

	carta_descarte_marcada.emit(carta)


func confirmar_descarte() -> void:
	if modo_actual != ModoInteraccion.SELECCIONAR_DESCARTE:
		return

	if seleccion_descarte_realizada:
		return

	if obtener_indice_carta(carta_ui_marcada) == -1:
		return

	if carta_ui_marcada.carta == null:
		push_warning(
			"Mano: la carta seleccionada no tiene CardData."
		)
		return

	seleccion_descarte_realizada = true
	btn_confirmar_descarte.disabled = true

	seleccion_descarte_resuelta.emit(carta_ui_marcada)
	
	
func finalizar_seleccion_descarte() -> void:
	_restaurar_modo_normal()


func cancelar_seleccion_descarte() -> void:
	if modo_actual != ModoInteraccion.SELECCIONAR_DESCARTE:
		return

	seleccion_descarte_realizada = true

	# Restaurar antes de notificar la cancelación.
	_restaurar_modo_normal()

	seleccion_descarte_resuelta.emit(null)


func _ui_descarte_valida() -> bool:
	return (
		is_instance_valid(ui_seleccion_descarte)
		and is_instance_valid(label_instruccion)
		and is_instance_valid(btn_confirmar_descarte)
	)


func _restaurar_modo_normal() -> void:
	modo_actual = ModoInteraccion.NORMAL

	carta_ui_marcada = null
	seleccion_descarte_realizada = false

	if _ui_descarte_valida():
		ui_seleccion_descarte.hide()
		btn_confirmar_descarte.disabled = true

	_actualizar_interaccion_cartas()
	actualizar_disponibilidad_todas()
	_actualizar_estado_visual_todas()


func _actualizar_interaccion_cartas() -> void:
	for hijo in get_children():
		if hijo is CardUI:
			hijo.permitir_arrastre = (
				not mano_cerrada
				and modo_actual == ModoInteraccion.NORMAL
				and not _esta_animando_robo(hijo)
			)
# ============================================================
# FINALIZACIÓN Y LIMPIEZA
# ============================================================

func finalizar_animaciones_robo() -> void:
	if is_instance_valid(animador_cartas):
		animador_cartas.finalizar_animaciones_robo()

	_actualizar_interaccion_cartas()
	
	
func cerrar_mano() -> void:
	mano_cerrada = true
	version_mano += 1
	cantidad_robadas_pendientes = 0

	_limpiar_cartas_visuales()
	if _ui_descarte_valida():
		ui_seleccion_descarte.hide()
	hide()
	set_process(false)


func _notificar_descarte_no_disponible() -> void:
	seleccion_descarte_resuelta.emit(null)
