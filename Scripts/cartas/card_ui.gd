class_name CardUI
extends Control

@onready var nombre_label: Label = $Panel/VBoxContainer/Nombre
@onready var costo_contenedor: HBoxContainer = $Panel/VBoxContainer/Costo
@onready var arte_rect: TextureRect = $Panel/TextureRect

signal carta_clickeada(carta: CardData)

var carta: CardData
var permitir_arrastre: bool = true

# ============================================================
# CONFIGURACIÓN VISUAL
# ============================================================

@export_group("Visualización de éteres")
@export_range(8, 40, 1) var tamano_eter: int = 18
@export_range(0, 20, 1) var separacion_eteres: int = 4

# Color del borde de los círculos.
const COLOR_BORDE := Color("#E8C66A")


# ============================================================
# CONFIGURAR CARTA
# ============================================================

func setear_carta(data: CardData) -> void:
	carta = data

	nombre_label.text = data.nombre

	if data.arte != null:
		arte_rect.texture = data.arte
	else:
		arte_rect.texture = null

	_actualizar_costo(data)


# ============================================================
# MOSTRAR COSTO DE ÉTER
# ============================================================

func _actualizar_costo(data: CardData) -> void:

	# Limpiar círculos anteriores.
	for hijo in costo_contenedor.get_children():
		costo_contenedor.remove_child(hijo)
		hijo.queue_free()

	costo_contenedor.add_theme_constant_override(
		"separation",
		separacion_eteres
	)

	# Cartas que todavía utilizan energía antigua.
	if data.costo_eter == null:
		var etiqueta := Label.new()
		etiqueta.text = "Costo: %d" % data.costo
		costo_contenedor.add_child(etiqueta)
		return

	var costos: Array[int] = (
		data.costo_eter.obtener_costos_especificos()
	)

	# --------------------------------------------------------
	# Éteres específicos
	# --------------------------------------------------------

	for color in range(costos.size()):
		for i in range(costos[color]):
			_crear_circulo(
				EtherColors.obtener_color(color)
			)

	# --------------------------------------------------------
	# Éteres genéricos
	# --------------------------------------------------------

	for i in range(data.costo_eter.generico):
		_crear_circulo(
			EtherColors.GENERICO
		)


# ============================================================
# CREAR CÍRCULO
# ============================================================


func _crear_circulo(color: Color) -> void:
	var circulo := Panel.new()

	circulo.custom_minimum_size = Vector2(
		tamano_eter,
		tamano_eter
	)

	circulo.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var estilo := StyleBoxFlat.new()

	estilo.bg_color = color
	estilo.set_corner_radius_all(tamano_eter)
	estilo.corner_detail = 12

	estilo.set_border_width_all(1)
	estilo.border_color = COLOR_BORDE

	# Aplicar el estilo al círculo.
	circulo.add_theme_stylebox_override("panel", estilo)

	costo_contenedor.add_child(circulo)

# ============================================================
# ARRASTRAR CARTA
# ============================================================

func _get_drag_data(_position):
	if not permitir_arrastre:
		return null
		
	if carta == null:
		return null

	var preview := TextureRect.new()
	preview.texture = arte_rect.texture
	preview.custom_minimum_size = Vector2(150, 220)

	set_drag_preview(preview)

	modulate.a = 0.4

	return carta


func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		modulate.a = 1.0
		
		
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if carta != null:
				carta_clickeada.emit(carta)
