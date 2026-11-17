class_name CardEffectResolver
extends Node

signal carta_finalizada(carta: CardData)

var contexto: CardEffectContext
var ejecutando: bool = false


func configurar(deck_manager: DeckManager) -> void:
	contexto = CardEffectContext.new(deck_manager)


func ejecutar_carta(
	carta: CardData,
	fuente: CombatEntity,
	objetivo: CombatEntity) -> void:

	if ejecutando:
		push_warning("Ya hay una carta ejecutándose.")
		return

	if contexto == null:
		push_error("CardEffectResolver no tiene contexto configurado.")
		return

	ejecutando = true

	for efecto: EffectData in carta.efectos:
		if efecto == null:
			continue

		await efecto.ejecutar(contexto, fuente, objetivo)

	ejecutando = false
	carta_finalizada.emit(carta)
