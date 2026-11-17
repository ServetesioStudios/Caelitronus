class_name CardPlayValidator
extends RefCounted

var deck_manager: DeckManager
var ether_manager: EtherManager
var combat_manager: CombatManager
var player: CombatEntity
var resolver: CardEffectResolver
var contexto: CardEffectContext

var motivo_no_jugable: String = ""


func _init(
	p_deck_manager: DeckManager,
	p_ether_manager: EtherManager,
	p_combat_manager: CombatManager,
	p_player: CombatEntity,
	p_resolver: CardEffectResolver) -> void:

	deck_manager = p_deck_manager
	ether_manager = p_ether_manager
	combat_manager = p_combat_manager
	player = p_player
	resolver = p_resolver
	contexto = resolver.contexto


func puede_jugar(
	carta: CardData,
	pago_pendiente: bool = false
) -> bool:

	motivo_no_jugable = ""

	# --------------------------------------------------------
	# VALIDACIONES GENERALES
	# --------------------------------------------------------

	if carta == null:
		motivo_no_jugable = "Carta no válida"
		return false

	if not combat_manager.es_turno_jugador():
		motivo_no_jugable = "No es tu turno"
		return false

	if not carta in deck_manager.mano:
		motivo_no_jugable = "Esta carta ya no está disponible"
		return false

	if resolver.ejecutando:
		motivo_no_jugable = "Espera a que termine el efecto actual"
		return false

	if pago_pendiente:
		motivo_no_jugable = "Termina o cancela el pago actual"
		return false

		
	# --------------------------------------------------------
	# VALIDACIÓN DE RECURSOS
	# --------------------------------------------------------

	if carta.costo_eter == null:
		motivo_no_jugable = "Esta carta no tiene un coste de éter configurado"
		return false

	if not ether_manager.puede_pagar(carta.costo_eter):
		motivo_no_jugable = "Éteres insuficientes"
		return false


	# --------------------------------------------------------
	# VALIDACIÓN DE REQUISITOS DE EFECTOS
	# --------------------------------------------------------

	for efecto: EffectData in carta.efectos:

		if efecto == null:
			continue

		if not efecto.puede_ejecutarse(contexto):
			motivo_no_jugable = "No se cumplen los requisitos de esta carta"
			return false

	# --------------------------------------------------------
	# CARTA JUGABLE
	# --------------------------------------------------------

	return true
