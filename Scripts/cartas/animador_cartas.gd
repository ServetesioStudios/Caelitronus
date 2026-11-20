class_name AnimadorCartas
extends Control

signal descartes_finalizados
signal reciclaje_finalizado

# ============================================================
# CONFIGURACIÓN
# ============================================================

@export_group("Animación de robo")
@export_range(0.05, 1.0, 0.01) var duracion_robo: float = 0.25
@export_range(0.1, 1.0, 0.05) var escala_inicial_robo: float = 0.3

@export_group("Animación de descarte")
@export_range(0.05, 1.0, 0.01) var duracion_descarte: float = 0.25
@export_range(0.1, 1.0, 0.05) var escala_final_descarte: float = 0.3

@export_group("Animación de reciclaje")
@export_range(1, 10, 1) var max_cartas_reciclaje: int = 5
@export_range(0.05, 1.0, 0.01) var duracion_reciclaje: float = 0.3
@export_range(0.0, 0.3, 0.01) var retraso_reciclaje: float = 0.08
@export_range(0.0, 0.5, 0.01) var pausa_reciclaje_robo: float = 0.1
@export_range(0.05, 1.0, 0.05) var escala_reciclaje: float = 0.2

@export_group("Sincronización")
@export_range(0.0, 0.5, 0.01) var pausa_descarte_robo: float = 0.1

@export_group("Referencias")
@export var origen_robo: Control
@export var destino_descarte: Control

# ============================================================
# VARIABLES
# ============================================================
const CARD_UI_SCENE := preload("res://Scenes/ui/card_ui.tscn")

var tweens_robo: Dictionary = {}
var tweens_descarte: Dictionary = {}
var tweens_reciclaje: Dictionary = {}

# ============================================================
# ANIMACIÓN DE ROBO
# ============================================================

func animar_robo(
	card_ui: CardUI,
	destino: Vector2,
	rotacion_final: float) -> Tween:

	if not is_instance_valid(card_ui):
		return null

	if not is_instance_valid(origen_robo):
		push_warning("AnimadorCartas: falta configurar el origen de robo.")
		return null

	var padre := card_ui.get_parent() as Control

	if padre == null:
		push_warning("AnimadorCartas: la carta no tiene un padre Control.")
		return null

	# Obtener el centro visual del mazo.
	var centro_mazo: Vector2 = (
		origen_robo.get_global_transform()
		* (origen_robo.size / 2.0)
	)

	# Convertir a coordenadas locales de la mano.
	var origen: Vector2 = (
		padre.get_global_transform().affine_inverse()
		* centro_mazo
	)

	# Cancelar una animación anterior, si existe.
	if tweens_robo.has(card_ui):
		finalizar_robo(card_ui)

	# Configurar estado inicial.
	card_ui.scale = Vector2.ONE * escala_inicial_robo
	card_ui.rotation_degrees = 0.0

	card_ui.position = (
		origen
		- card_ui.pivot_offset
		- (card_ui.size / 2.0 - card_ui.pivot_offset)
		* escala_inicial_robo
	)

	# Crear animación.
	var tween := card_ui.create_tween()

	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		card_ui,
		"position",
		destino,
		duracion_robo
	)

	tween.tween_property(
		card_ui,
		"scale",
		Vector2.ONE,
		duracion_robo
	)

	tween.tween_property(
		card_ui,
		"rotation_degrees",
		rotacion_final,
		duracion_robo
	)

	tweens_robo[card_ui] = {
		"tween": tween,
		"destino": destino,
		"rotacion": rotacion_final
	}

	tween.finished.connect(
		func():
			tweens_robo.erase(card_ui)
	)

	return tween


# ============================================================
# ANIMACIÓN DE DESCARTE
# ============================================================

func animar_descarte(
	carta: CardData,
	centro_global: Vector2,
	tamano: Vector2,
	rotacion_inicial: float = 0.0,
	escala_inicial: Vector2 = Vector2.ONE) -> void:

	if carta == null:
		return

	if not is_instance_valid(destino_descarte):
		push_warning("AnimadorCartas: falta el destino de descarte.")
		return

	# Crear una copia exclusivamente visual.
	var copia := CARD_UI_SCENE.instantiate() as CardUI

	if copia == null:
		return

	copia.process_mode = Node.PROCESS_MODE_DISABLED

	add_child(copia)

	copia.setear_carta(carta)
	copia.permitir_arrastre = false

	_desactivar_interaccion(copia)

	# Configurar dimensiones y transformación.
	copia.custom_minimum_size = tamano
	copia.size = tamano
	copia.pivot_offset = copia.size / 2.0
	copia.rotation_degrees = rotacion_inicial
	copia.scale = escala_inicial

	# Convertir el origen global a coordenadas del animador.
	var origen: Vector2 = (
		get_global_transform().affine_inverse()
		* centro_global
	)

	copia.position = origen - copia.pivot_offset

	# Obtener el centro del mazo de descarte.
	var centro_destino: Vector2 = (
		destino_descarte.get_global_transform()
		* (destino_descarte.size / 2.0)
	)

	var destino: Vector2 = (
		get_global_transform().affine_inverse()
		* centro_destino
	)

	destino -= copia.pivot_offset

	# Crear animación.
	var tween := create_tween()

	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		copia, "position", destino, duracion_descarte)

	tween.tween_property(
		copia, "scale",
		Vector2.ONE * escala_final_descarte,
		duracion_descarte)

	tween.tween_property(
		copia, "rotation_degrees", 0.0, duracion_descarte)

	tweens_descarte[copia] = tween

	tween.finished.connect(
		_finalizar_descarte.bind(copia)
	)


# ============================================================
# ANIMACIÓN DE RECICLAJE
# ============================================================

func animar_reciclaje(cantidad_cartas: int) -> void:
	if cantidad_cartas <= 0:
		return

	if hay_reciclaje_activo():
		return

	if not is_instance_valid(destino_descarte):
		return

	if not is_instance_valid(origen_robo):
		return

	# Obtener los TextureRect de ambos mazos.
	var mazo_origen := destino_descarte.get_node_or_null("TextureRect") as TextureRect
	var mazo_destino := origen_robo.get_node_or_null("TextureRect") as TextureRect

	if not is_instance_valid(mazo_origen):
		push_warning("AnimadorCartas: falta el TextureRect de descarte.")
		return

	if not is_instance_valid(mazo_destino):
		push_warning("AnimadorCartas: falta el TextureRect de robo.")
		return

	if mazo_origen.texture == null:
		push_warning("AnimadorCartas: falta la textura del reverso.")
		return

	# Limitar la cantidad de cartas visuales.
	var cantidad_visual: int = mini(
		cantidad_cartas, max_cartas_reciclaje)

	# Convertir los centros a coordenadas locales.
	var inversa: Transform2D = (
		get_global_transform().affine_inverse())

	var origen: Vector2 = (
		inversa * mazo_origen.get_global_transform()
		* (mazo_origen.size / 2.0))

	var destino: Vector2 = (
		inversa * mazo_destino.get_global_transform()
		* (mazo_destino.size / 2.0))

	# Crear las cartas visuales.
	for i in range(cantidad_visual):
		var copia := TextureRect.new()
		
		copia.z_as_relative = false
		copia.z_index = 0

		copia.texture = mazo_origen.texture
		copia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		copia.stretch_mode = mazo_origen.stretch_mode
		copia.mouse_filter = Control.MOUSE_FILTER_IGNORE
		copia.focus_mode = Control.FOCUS_NONE

		add_child(copia)

		copia.size = mazo_origen.size * escala_reciclaje
		copia.position = origen - copia.size / 2.0

		# Ocultar hasta que comience el movimiento.
		copia.hide()

		var tween := create_tween()

		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_IN_OUT)

		# Retraso escalonado entre cartas.
		if i > 0:
			tween.tween_interval(i * retraso_reciclaje)

		tween.tween_callback(copia.show)

		tween.tween_property(
			copia,
			"position",
			destino - copia.size / 2.0,
			duracion_reciclaje
		)

		tweens_reciclaje[copia] = tween

		tween.finished.connect(
			_finalizar_reciclaje.bind(copia)
		)


# ============================================================
# CONSULTAS
# ============================================================

func esta_animando_robo(card_ui: CardUI) -> bool:
	return tweens_robo.has(card_ui)


func hay_robos_activos() -> bool:
	return not tweens_robo.is_empty()


func hay_descartes_activos() -> bool:
	return not tweens_descarte.is_empty()


func hay_reciclaje_activo() -> bool:
	return not tweens_reciclaje.is_empty()


# ============================================================
# ESPERAS DE ANIMACIONES
# ============================================================

func esperar_descartes() -> void:
	if not hay_descartes_activos():
		return

	await descartes_finalizados


func esperar_reciclaje() -> void:
	if not hay_reciclaje_activo():
		return

	await reciclaje_finalizado


# ============================================================
# FINALIZACIÓN DE ROBO
# ============================================================

func finalizar_robo(card_ui: CardUI) -> void:
	if not tweens_robo.has(card_ui):
		return

	var datos: Dictionary = tweens_robo[card_ui]
	var tween: Tween = datos["tween"]

	if tween != null and tween.is_valid():
		tween.kill()

	if is_instance_valid(card_ui):
		card_ui.position = datos["destino"]
		card_ui.rotation_degrees = datos["rotacion"]
		card_ui.scale = Vector2.ONE

	tweens_robo.erase(card_ui)


func finalizar_animaciones_robo() -> void:
	for card_ui in tweens_robo.keys():
		finalizar_robo(card_ui)


# ============================================================
# FINALIZACIÓN Y CANCELACIÓN DE DESCARTE
# ============================================================

func _finalizar_descarte(copia: CardUI) -> void:
	tweens_descarte.erase(copia)

	if is_instance_valid(copia):
		copia.queue_free()

	if tweens_descarte.is_empty():
		descartes_finalizados.emit()


func cancelar_animaciones_descarte() -> void:
	var habia_descartes: bool = hay_descartes_activos()

	for copia in tweens_descarte.keys():
		var tween: Tween = tweens_descarte[copia]

		if tween != null and tween.is_valid():
			tween.kill()

		if is_instance_valid(copia):
			copia.queue_free()

	tweens_descarte.clear()

	if habia_descartes:
		descartes_finalizados.emit()


# ============================================================
# FINALIZACIÓN Y CANCELACIÓN DE RECICLAJE
# ============================================================

func _finalizar_reciclaje(copia: TextureRect) -> void:
	tweens_reciclaje.erase(copia)

	if is_instance_valid(copia):
		copia.queue_free()

	if tweens_reciclaje.is_empty():
		reciclaje_finalizado.emit()


func cancelar_animaciones_reciclaje() -> void:
	var habia_reciclaje: bool = hay_reciclaje_activo()

	for copia in tweens_reciclaje.keys():
		var tween: Tween = tweens_reciclaje[copia]

		if tween != null and tween.is_valid():
			tween.kill()

		if is_instance_valid(copia):
			copia.queue_free()

	tweens_reciclaje.clear()

	if habia_reciclaje:
		reciclaje_finalizado.emit()


# ============================================================
# UTILIDADES
# ============================================================

func _desactivar_interaccion(nodo: Node) -> void:
	if nodo is Control:
		nodo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nodo.focus_mode = Control.FOCUS_NONE

	for hijo in nodo.get_children():
		_desactivar_interaccion(hijo)
