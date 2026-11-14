extends Control

signal carta_soltada(carta: CardData, posicion_global: Vector2)


# ============================================================
# CONFIGURACIÓN VISUAL
# ============================================================

@export_group("Carta suspendida")
@export var fuente_mensaje: Font
@export_range(8, 48, 1) var tamano_fuente: int = 16

const TAMANO_CARTA := Vector2(170, 115)


# ============================================================
# VARIABLES
# ============================================================

var carta_pendiente_visual: PanelContainer
var texto_carta: Label


# ============================================================
# INICIALIZACIÓN
# ============================================================

func _ready() -> void:
	_crear_carta_pendiente_visual()


# ============================================================
# DRAG & DROP
# ============================================================

func _can_drop_data(_at_position: Vector2, data) -> bool:
	return data is CardData


func _drop_data(_at_position: Vector2, data) -> void:
	carta_soltada.emit(
		data,
		get_global_mouse_position()
	)


# ============================================================
# CREACIÓN DE CARTA SUSPENDIDA
# ============================================================

func _crear_carta_pendiente_visual() -> void:
	carta_pendiente_visual = PanelContainer.new()

	carta_pendiente_visual.custom_minimum_size = TAMANO_CARTA
	carta_pendiente_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	carta_pendiente_visual.visible = false
	carta_pendiente_visual.z_index = 10

	# --------------------------------------------------------
	# Estilo del panel
	# --------------------------------------------------------

	var estilo := StyleBoxFlat.new()

	estilo.bg_color = Color("#352C35")
	estilo.border_color = Color("#E8C66A")

	estilo.set_border_width_all(3)
	estilo.set_corner_radius_all(10)
	estilo.set_content_margin_all(12)

	carta_pendiente_visual.add_theme_stylebox_override(
		"panel",
		estilo
	)

	# --------------------------------------------------------
	# Crear Label
	# --------------------------------------------------------

	texto_carta = Label.new()

	texto_carta.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	texto_carta.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	texto_carta.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	texto_carta.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	# --------------------------------------------------------
	# Fuente personalizada
	# --------------------------------------------------------

	if fuente_mensaje != null:
		texto_carta.add_theme_font_override(
			"font",
			fuente_mensaje
		)

	texto_carta.add_theme_font_size_override(
		"font_size",
		tamano_fuente
	)

	# --------------------------------------------------------
	# Agregar nodos
	# --------------------------------------------------------

	carta_pendiente_visual.add_child(texto_carta)
	add_child(carta_pendiente_visual)


# ============================================================
# MOSTRAR CARTA PENDIENTE
# ============================================================

func mostrar_carta_pendiente(
	carta: CardData,
	posicion_global: Vector2
) -> void:

	if carta == null:
		return

	# Mostrar nombre y mensaje de espera.
	texto_carta.text = (
		carta.nombre
		+ "\n\n"
		+ "Esperando pago de éter..."
	)

	# Convertir posición global a local.
	var posicion_local := (
		get_global_transform().affine_inverse()
		* posicion_global
		- TAMANO_CARTA / 2.0
	)

	# Limitar posición dentro de DropZone.
	posicion_local.x = clampf(
		posicion_local.x,
		0.0,
		maxf(0.0, size.x - TAMANO_CARTA.x)
	)

	posicion_local.y = clampf(
		posicion_local.y,
		0.0,
		maxf(0.0, size.y - TAMANO_CARTA.y)
	)

	# Mostrar carta.
	carta_pendiente_visual.position = posicion_local
	carta_pendiente_visual.show()


# ============================================================
# OCULTAR CARTA PENDIENTE
# ============================================================

func ocultar_carta_pendiente() -> void:
	if carta_pendiente_visual != null:
		carta_pendiente_visual.hide()
