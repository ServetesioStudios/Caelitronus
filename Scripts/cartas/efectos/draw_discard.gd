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
	_objetivo: CombatEntity) -> void:

	# Descartar las cartas seleccionadas.
	for i in range(cantidad_descartar):
		var carta: CardData = await contexto.solicitar_descarte()

		if carta == null:
			push_warning(
				"DrawDiscardEffectData: no se pudo seleccionar una carta."
			)
			return

		contexto.descartar_carta(carta)

	# Robar después de completar el descarte.
	if cantidad_robar > 0:
		contexto.robar_cartas(cantidad_robar)
