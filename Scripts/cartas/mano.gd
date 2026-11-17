extends Control

const CARD_UI_SCENE := preload("res://Scenes/ui/card_ui.tscn")

enum ModoInteraccion {
		NORMAL, 
		SELECCIONAR_DESCARTE
}

signal carta_seleccionada(carta: CardData)
signal seleccion_descarte_resuelta(carta: CardData)


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


@onready var tooltip: CardTooltip = $"../CardTooltip"

var carta_hover: CardUI = null
var tweens_cartas: Dictionary = {}

var posiciones_originales: Dictionary = {}
var rotaciones_originales: Dictionary = {}
var indices_originales: Dictionary = {}

var tiempo_hover: float = 0.0
var tooltip_visible: bool = false

var card_play_validator: CardPlayValidator

var modo_actual: ModoInteraccion = ModoInteraccion.NORMAL
var seleccion_descarte_realizada: bool = false


func _process(delta: float) -> void:
	if posiciones_originales.is_empty():
		return

	var mouse_pos: Vector2 = get_global_mouse_position()
	var carta_detectada: CardUI = null

	var cartas := get_children()

	for i in range(cartas.size() - 1, -1, -1):
		var carta := cartas[i] as CardUI

		if carta == null:
			continue

		if not posiciones_originales.has(carta):
			continue

		# Usar la posición original, no la animada.
		var posicion_original: Vector2 = posiciones_originales[carta]

		# Convertir la posición local de la mano a global.
		var posicion_global: Vector2 = get_global_transform() * posicion_original

		var rect := Rect2(
			posicion_global + Vector2(margen_hover, margen_hover),
			Vector2(
				ancho_carta - margen_hover * 2.0,
				alto_carta - margen_hover * 2.0
			)
		)

		if rect.has_point(mouse_pos):
			carta_detectada = carta
			break

	if carta_detectada != carta_hover:
		_cambiar_hover(carta_detectada)

	if carta_hover == null:
		return

	tiempo_hover += delta

	if tiempo_hover >= retraso_tooltip and not tooltip_visible:
		_mostrar_tooltip()


func _cambiar_hover(nueva_carta: CardUI) -> void:
	tiempo_hover = 0.0
	tooltip_visible = false
	tooltip.ocultar()

	if carta_hover != null and is_instance_valid(carta_hover):
		if posiciones_originales.has(carta_hover):
			_animar_carta(
				carta_hover,
				posiciones_originales[carta_hover],
				rotaciones_originales[carta_hover],
				indices_originales[carta_hover]
			)

	carta_hover = nueva_carta

	if carta_hover != null:
		if posiciones_originales.has(carta_hover):
			_animar_carta(
				carta_hover,
				posiciones_originales[carta_hover] -
				Vector2(0, elevacion_hover),
				0.0,
				100
			)
			
			
func _animar_carta(
	carta: CardUI,
	destino: Vector2,
	rotacion: float,
	indice: int) -> void:
	
	if tweens_cartas.has(carta):
		var tween_anterior: Tween = tweens_cartas[carta]

		if tween_anterior != null and tween_anterior.is_running():
			tween_anterior.kill()

	carta.z_index = indice

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


func mostrar_mano(cartas: Array[CardData]) -> void:
	carta_hover = null
	tiempo_hover = 0.0
	tooltip_visible = false
	tooltip.ocultar()

	posiciones_originales.clear()
	rotaciones_originales.clear()
	indices_originales.clear()

	for tween in tweens_cartas.values():
		if tween != null and tween.is_running():
			tween.kill()

	tweens_cartas.clear()

	for hijo in get_children():
		remove_child(hijo)
		hijo.queue_free()

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

	# Esperar a que los controles calculen sus tamaños.
	await get_tree().process_frame

	_distribuir_cartas()


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

	var inicio_x: float = (size.x - ancho_total) / 2.0

	# Altura de referencia de la carta central.
	var base_y: float = size.y - alto_carta - 35.0

	for i in range(cantidad):
		var carta: CardUI = cartas[i]

		# Valores normalizados entre -1 y 1.
		var t: float = 0.0

		if cantidad > 1:
			t = (
				float(i) - float(cantidad - 1) / 2.0
			) / (
				float(cantidad - 1) / 2.0
			)

		# Curva: el centro queda arriba
		# y los extremos bajan progresivamente.
		var desplazamiento_y: float = (
			t * t * altura_arco
		)

		var posicion_x: float = (
			inicio_x + i * separacion
		)

		var posicion_y: float = (
			base_y + desplazamiento_y
		)

		carta.pivot_offset = Vector2(
			ancho_carta / 2.0,
			alto_carta
		)

		carta.position = Vector2(
			posicion_x,
			posicion_y
		)

		carta.rotation_degrees = (
			t * rotacion_maxima
		)

		# Las cartas cercanas al centro
		# quedan por encima de las laterales.
		carta.z_index = (
			cantidad - absi(i - int(cantidad / 2))
		)
	
		posiciones_originales[carta] = carta.position
		rotaciones_originales[carta] = carta.rotation_degrees
		indices_originales[carta] = carta.z_index


func actualizar_disponibilidad_todas() -> void:
	for card_ui in get_children():
		if card_ui is CardUI:
			_actualizar_disponibilidad(card_ui)


func _actualizar_disponibilidad(card_ui: CardUI) -> void:
	if card_ui.carta == null:
		return

	# Durante el descarte, todas las cartas son seleccionables.
	if modo_actual == ModoInteraccion.SELECCIONAR_DESCARTE:
		card_ui.modulate = Color.WHITE
		return

	if card_play_validator == null:
		card_ui.modulate = Color.WHITE
		return

	var carta_jugable: bool = card_play_validator.puede_jugar(
		card_ui.carta
	)

	if carta_jugable:
		card_ui.modulate = Color.WHITE
	else:
		card_ui.modulate = Color(0.45, 0.45, 0.45, 1.0)
			

func _mostrar_tooltip() -> void:
	if carta_hover == null or not is_instance_valid(carta_hover):
		return

	if carta_hover.carta == null:
		return

	tooltip.mostrar_carta(carta_hover.carta)

	var posicion: Vector2 = carta_hover.global_position

	posicion.x += (carta_hover.size.x - tooltip.size.x) / 2.0
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


func iniciar_seleccion_descarte() -> void:
	seleccion_descarte_realizada = false
	modo_actual = ModoInteraccion.SELECCIONAR_DESCARTE
	_actualizar_interaccion_cartas()
	actualizar_disponibilidad_todas()


func finalizar_seleccion_descarte() -> void:
	modo_actual = ModoInteraccion.NORMAL
	seleccion_descarte_realizada = false
	_actualizar_interaccion_cartas()
	actualizar_disponibilidad_todas()

	
func _on_carta_clickeada(carta: CardData) -> void:
	if modo_actual != ModoInteraccion.SELECCIONAR_DESCARTE:
		return

	if seleccion_descarte_realizada:
		return

	if carta == null:
		return

	seleccion_descarte_realizada = true
	seleccion_descarte_resuelta.emit(carta)

	
func cancelar_seleccion_descarte() -> void:
	if modo_actual != ModoInteraccion.SELECCIONAR_DESCARTE:
		return

	seleccion_descarte_realizada = true
	seleccion_descarte_resuelta.emit(null)
	finalizar_seleccion_descarte()
	
	
func _actualizar_interaccion_cartas() -> void:
	for hijo in get_children():
		if hijo is CardUI:
			hijo.permitir_arrastre = (
				modo_actual == ModoInteraccion.NORMAL
			)
