extends Control

const CARD_UI_SCENE := preload("res://Scenes/ui/card_ui.tscn")

const COLOR_SELECCION := Color("#FFD700")
const COLOR_NO_JUGABLE := Color(0.45, 0.45, 0.45, 1.0)
const Z_INDEX_ELEVADO := 100

enum ModoInteraccion {
	NORMAL,
	SELECCIONAR_DESCARTE
}

signal carta_seleccionada(carta: CardData)
signal seleccion_descarte_resuelta(carta: CardData)
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

@onready var tooltip: CardTooltip = $"../CardTooltip"

@onready var ui_seleccion_descarte: Control = (
	$"../UISeleccionDescarte"
)

@onready var label_instruccion: Label = (
	$"../UISeleccionDescarte/LabelInstruccion"
)

@onready var btn_confirmar_descarte: Button = (
	$"../UISeleccionDescarte/BtnConfirmarDescarte"
)


# ============================================================
# ESTADO
# ============================================================

var card_play_validator: CardPlayValidator

var modo_actual: ModoInteraccion = ModoInteraccion.NORMAL

var carta_hover: CardUI = null
var carta_marcada_descarte: CardData = null

var seleccion_descarte_realizada: bool = false

var tiempo_hover: float = 0.0
var tooltip_visible: bool = false

var posiciones_originales: Dictionary = {}
var rotaciones_originales: Dictionary = {}
var indices_originales: Dictionary = {}

var tweens_cartas: Dictionary = {}

# Evita distribuir una reconstrucción anterior.
var version_mano: int = 0


# ============================================================
# INICIALIZACIÓN
# ============================================================

func _ready() -> void:
	btn_confirmar_descarte.pressed.connect(confirmar_descarte)

	ui_seleccion_descarte.hide()
	btn_confirmar_descarte.disabled = true


# ============================================================
# DETECCIÓN DE HOVER
# ============================================================

func _process(delta: float) -> void:
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

		if card_ui == null:
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
		and carta_marcada_descarte != null
		and card_ui.carta == carta_marcada_descarte
	)


func _actualizar_estado_visual_carta(card_ui: CardUI) -> void:
	if not is_instance_valid(card_ui):
		return

	if not posiciones_originales.has(card_ui):
		return

	var elevada: bool = (
		card_ui == carta_hover
		or _es_carta_marcada(card_ui)
	)

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
	indice: int
) -> void:
	if tweens_cartas.has(carta):
		var tween_anterior: Tween = tweens_cartas[carta]

		if tween_anterior != null and tween_anterior.is_running():
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


# ============================================================
# CONSTRUCCIÓN DE LA MANO
# ============================================================

func mostrar_mano(cartas: Array[CardData]) -> void:
	version_mano += 1
	var version_actual: int = version_mano

	_limpiar_cartas_visuales()

	for carta in cartas:
		var card_ui := CARD_UI_SCENE.instantiate() as CardUI

		add_child(card_ui)

		card_ui.carta_clickeada.connect(_on_carta_clickeada)

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

	_distribuir_cartas()


func _limpiar_cartas_visuales() -> void:
	_ocultar_tooltip()
	carta_hover = null

	for tween in tweens_cartas.values():
		if tween != null and tween.is_running():
			tween.kill()

	tweens_cartas.clear()

	posiciones_originales.clear()
	rotaciones_originales.clear()
	indices_originales.clear()

	for hijo in get_children():
		if hijo is CardUI:
			remove_child(hijo)
			hijo.queue_free()


# ============================================================
# DISTRIBUCIÓN DE CARTAS
# ============================================================

func _distribuir_cartas() -> void:
	var cartas: Array[CardUI] = []

	posiciones_originales.clear()
	rotaciones_originales.clear()
	indices_originales.clear()

	for hijo in get_children():
		if hijo is CardUI:
			cartas.append(hijo)

	var cantidad: int = cartas.size()

	if cantidad == 0:
		return

	var ancho_total: float = (
		ancho_carta + (cantidad - 1) * separacion
	)

	var inicio_x: float = (
		size.x - ancho_total
	) / 2.0

	var base_y: float = (
		size.y - alto_carta - 35.0
	)

	for i in range(cantidad):
		var card_ui: CardUI = cartas[i]

		var t: float = 0.0

		if cantidad > 1:
			t = (
				float(i) - float(cantidad - 1) / 2.0
			) / (
				float(cantidad - 1) / 2.0
			)

		var desplazamiento_y: float = (
			t * t * altura_arco
		)

		var posicion_x: float = (
			inicio_x + i * separacion
		)

		var posicion_y: float = (
			base_y + desplazamiento_y
		)

		card_ui.pivot_offset = Vector2(
			ancho_carta / 2.0,
			alto_carta
		)

		card_ui.position = Vector2(
			posicion_x,
			posicion_y
		)

		card_ui.rotation_degrees = (
			t * rotacion_maxima
		)

		card_ui.z_index = (
			cantidad - absi(i - int(cantidad / 2))
		)

		posiciones_originales[card_ui] = card_ui.position
		rotaciones_originales[card_ui] = card_ui.rotation_degrees
		indices_originales[card_ui] = card_ui.z_index

	_actualizar_estado_visual_todas()


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
	tooltip.ocultar()


func _mostrar_tooltip() -> void:
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
	modo_actual = ModoInteraccion.SELECCIONAR_DESCARTE

	seleccion_descarte_realizada = false
	carta_marcada_descarte = null

	label_instruccion.text = (
		"Seleccioná una carta para descartar"
	)

	btn_confirmar_descarte.disabled = true
	ui_seleccion_descarte.show()

	_actualizar_interaccion_cartas()
	actualizar_disponibilidad_todas()
	_actualizar_estado_visual_todas()


func _on_carta_clickeada(carta: CardData) -> void:
	if modo_actual != ModoInteraccion.SELECCIONAR_DESCARTE:
		return

	if seleccion_descarte_realizada:
		return

	if carta == null:
		return

	carta_marcada_descarte = carta

	btn_confirmar_descarte.disabled = false

	actualizar_disponibilidad_todas()
	_actualizar_estado_visual_todas()

	carta_descarte_marcada.emit(carta)


func confirmar_descarte() -> void:
	if modo_actual != ModoInteraccion.SELECCIONAR_DESCARTE:
		return

	if seleccion_descarte_realizada:
		return

	if carta_marcada_descarte == null:
		return

	seleccion_descarte_realizada = true
	btn_confirmar_descarte.disabled = true

	seleccion_descarte_resuelta.emit(carta_marcada_descarte)


func finalizar_seleccion_descarte() -> void:
	_restaurar_modo_normal()


func cancelar_seleccion_descarte() -> void:
	if modo_actual != ModoInteraccion.SELECCIONAR_DESCARTE:
		return

	seleccion_descarte_realizada = true

	# Restaurar antes de notificar la cancelación.
	_restaurar_modo_normal()

	seleccion_descarte_resuelta.emit(null)


func _restaurar_modo_normal() -> void:
	modo_actual = ModoInteraccion.NORMAL

	carta_marcada_descarte = null
	seleccion_descarte_realizada = false

	ui_seleccion_descarte.hide()
	btn_confirmar_descarte.disabled = true

	_actualizar_interaccion_cartas()
	actualizar_disponibilidad_todas()
	_actualizar_estado_visual_todas()


func _actualizar_interaccion_cartas() -> void:
	var permitir: bool = (
		modo_actual == ModoInteraccion.NORMAL
	)

	for hijo in get_children():
		if hijo is CardUI:
			hijo.permitir_arrastre = permitir
