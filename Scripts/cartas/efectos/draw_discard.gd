class_name DrawDiscardEffectData
extends EffectData

@export_group("Descarte")
@export_range(0, 5, 1) var cantidad_descartar: int = 1

@export_group("Robo")
@export_range(0, 5, 1) var cantidad_robar: int = 2


# ============================================================
# VALIDACIÓN
# ============================================================

func puede_ejecutarse(contexto: CardEffectContext) -> bool:
	if contexto == null:
		return false

	# La carta que se está jugando todavía está en la mano
	# cuando se realiza la validación.
	var cartas_disponibles: int = (
		contexto.cantidad_cartas_en_mano() - 1)

	return cartas_disponibles >= cantidad_descartar


# ============================================================
# EJECUCIÓN
# ============================================================

func ejecutar(
	contexto: CardEffectContext,
	_fuente: CombatEntity,
	_objetivo: CombatEntity
) -> void:

	# Descartar las cartas seleccionadas.
	for i in range(cantidad_descartar):
		var card_ui: CardUI = await contexto.solicitar_descarte()

		if not is_instance_valid(card_ui):
			push_warning(
				"DrawDiscardEffectData: no se pudo seleccionar una carta."
			)
			return

		if not contexto.descartar_carta(card_ui):
			return

	# Robar después de completar el descarte.
	if cantidad_robar > 0:
		contexto.robar_cartas(cantidad_robar)
