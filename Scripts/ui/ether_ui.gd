class_name EtherUI
extends Control

signal seleccion_actualizada(indices: Array[int])

@export var ether_manager: EtherManager

@onready var contenedor: HBoxContainer = $HBoxContainer
@onready var mensaje_seleccion: Label = $Label_elegirEter


# ============================================================
# CONFIGURACIÓN VISUAL
# ============================================================

const TAMANO_ICONO := Vector2(45, 45)

# Colores de interacción (no representan tipos de éter).
const COLOR_BORDE := Color("#FFFFFF")
const COLOR_RESERVADO := Color("#E8C66A")
const COLOR_DISPONIBLE := Color("#F3D587")


# ============================================================
# VARIABLES
# ============================================================

var modo_seleccion: bool = false
var cantidad_seleccionar: int = 0

var indices_seleccionados: Array[int] = []
var indices_reservados: Array[int] = []

var botones: Array[Button] = []
var tweens: Array[Tween] = []


# ============================================================
# INICIALIZACIÓN
# ============================================================

func _ready() -> void:
	if ether_manager == null:
		push_error("EtherUI: falta asignar EtherManager.")
		return

	contenedor.add_theme_constant_override("separation", 8)

	ether_manager.eteres_actualizados.connect(
		actualizar_eteres
	)

	actualizar_eteres()
	mensaje_seleccion.hide()


# ============================================================
# ACTUALIZACIÓN VISUAL
# ============================================================

func actualizar_eteres() -> void:
	_detener_animaciones()

	for hijo in contenedor.get_children():
		contenedor.remove_child(hijo)
		hijo.queue_free()

	botones.clear()

	for i in range(EtherManager.CANTIDAD_ETERES):
		var boton := Button.new()

		boton.custom_minimum_size = TAMANO_ICONO
		boton.focus_mode = Control.FOCUS_NONE

		boton.pressed.connect(
			_on_eter_presionado.bind(i)
		)

		contenedor.add_child(boton)
		botones.append(boton)

	_actualizar_estados_visuales()


func _actualizar_estados_visuales() -> void:
	_detener_animaciones()

	for i in range(botones.size()):
		var boton: Button = botones[i]

		var color_eter: int = EtherManager.ETER_VACIO

		if i < ether_manager.eteres.size():
			color_eter = ether_manager.eteres[i]

		var disponible: bool = (
			color_eter != EtherManager.ETER_VACIO
		)

		var reservado: bool = indices_reservados.has(i)
		var seleccionado: bool = indices_seleccionados.has(i)

		var puede_seleccionar: bool = (
			modo_seleccion
			and disponible
			and not reservado
		)

		boton.disabled = not puede_seleccionar

		# ----------------------------------------------------
		# Obtener color desde EtherColors
		# ----------------------------------------------------

		var color_fondo: Color = (
			EtherColors.obtener_color(color_eter)
		)

		# ----------------------------------------------------
		# Crear estilo del círculo
		# ----------------------------------------------------

		var estilo := StyleBoxFlat.new()
		estilo.bg_color = color_fondo

		estilo.set_corner_radius_all(30)
		estilo.corner_detail = 12

		if seleccionado:
			estilo.set_border_width_all(4)
			estilo.border_color = COLOR_BORDE

		elif reservado:
			estilo.set_border_width_all(4)
			estilo.border_color = COLOR_RESERVADO

		elif puede_seleccionar:
			estilo.set_border_width_all(4)
			estilo.border_color = COLOR_DISPONIBLE

		boton.add_theme_stylebox_override(
			"normal",
			estilo
		)

		boton.add_theme_stylebox_override(
			"hover",
			estilo
		)

		boton.add_theme_stylebox_override(
			"pressed",
			estilo
		)

		boton.add_theme_stylebox_override(
			"disabled",
			estilo
		)

		boton.modulate = Color.WHITE
		boton.scale = Vector2.ONE

		if puede_seleccionar and not seleccionado:
			_animar_pulso(boton)


# ============================================================
# SELECCIÓN
# ============================================================

func iniciar_seleccion(
	cantidad: int,
	reservados: Array[int] = []
) -> void:
	cancelar_seleccion()

	modo_seleccion = true
	cantidad_seleccionar = cantidad
	indices_reservados = reservados.duplicate()

	if cantidad == 1:
		mensaje_seleccion.text = "Elegí 1 éter"
	else:
		mensaje_seleccion.text = "Elegí %d éteres" % cantidad

	mensaje_seleccion.show()

	_actualizar_estados_visuales()


func cancelar_seleccion() -> void:
	modo_seleccion = false
	cantidad_seleccionar = 0

	indices_seleccionados.clear()
	indices_reservados.clear()

	if mensaje_seleccion != null:
		mensaje_seleccion.hide()

	_actualizar_estados_visuales()


func _on_eter_presionado(indice: int) -> void:
	if not modo_seleccion:
		return

	if indice < 0 or indice >= ether_manager.eteres.size():
		return

	if ether_manager.eteres[indice] == EtherManager.ETER_VACIO:
		return

	if indices_reservados.has(indice):
		return

	if indices_seleccionados.has(indice):
		indices_seleccionados.erase(indice)

	elif indices_seleccionados.size() < cantidad_seleccionar:
		indices_seleccionados.append(indice)

	_actualizar_estados_visuales()

	seleccion_actualizada.emit(
		indices_seleccionados.duplicate()
	)


func seleccion_completa() -> bool:
	return (
		modo_seleccion
		and indices_seleccionados.size() == cantidad_seleccionar
	)


func obtener_seleccion() -> Array[int]:
	return indices_seleccionados.duplicate()


# ============================================================
# ANIMACIONES
# ============================================================

func _animar_pulso(boton: Button) -> void:
	boton.pivot_offset = TAMANO_ICONO / 2.0

	var tween := create_tween()
	tween.set_loops()

	tween.tween_property(
		boton,
		"scale",
		Vector2(1.13, 1.13),
		0.45
	)

	tween.tween_property(
		boton,
		"scale",
		Vector2.ONE,
		0.45
	)

	tweens.append(tween)


func _detener_animaciones() -> void:
	for tween in tweens:
		if tween != null and tween.is_running():
			tween.kill()

	tweens.clear()
