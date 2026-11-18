class_name AnimadorCartas
extends Control

# ============================================================
# CONFIGURACIÓN
# ============================================================

@export_group("Animación de robo")
@export_range(0.05, 1.0, 0.01) var duracion_robo: float = 0.25
@export_range(0.1, 1.0, 0.05) var escala_inicial_robo: float = 0.3

@export_group("Referencias")
@export var origen_robo: Control

# ============================================================
# VARIABLES
# ============================================================

var tweens_robo: Dictionary = {}


# ============================================================
# ANIMACIÓN DE ROBO
# ============================================================

func animar_robo(
	card_ui: CardUI,
	destino: Vector2,
	rotacion_final: float
) -> Tween:

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
# CONSULTAS
# ============================================================

func esta_animando_robo(card_ui: CardUI) -> bool:
	return tweens_robo.has(card_ui)


# ============================================================
# FINALIZAR ANIMACIONES
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
