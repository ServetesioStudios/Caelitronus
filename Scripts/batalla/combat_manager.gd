class_name CombatManager
extends Node

var player: Player

signal turno_jugador_iniciado
signal turno_enemigo_iniciado
signal enemigo_actuo(enemigo: Enemy)
signal combate_terminado(victoria: bool)
signal energia_actualizada(actual: int, maxima: int)

enum Estado { INICIO, TURNO_JUGADOR, TURNO_ENEMIGO, VICTORIA, DERROTA }

var estado: Estado = Estado.INICIO
var enemigos: Array[Enemy] = []

var bloqueo: int = 0

func iniciar_combate(p: CombatEntity, e: Array[Enemy]) -> void:
	player = p
	enemigos = e
	_iniciar_turno_jugador()

func _iniciar_turno_jugador() -> void:
	estado = Estado.TURNO_JUGADOR
	player.resetear_energia()
	turno_jugador_iniciado.emit()

func finalizar_turno_jugador() -> void:
	if estado != Estado.TURNO_JUGADOR:
		return
	_iniciar_turno_enemigo()

func _iniciar_turno_enemigo() -> void:
	estado = Estado.TURNO_ENEMIGO
	turno_enemigo_iniciado.emit()
	await _ejecutar_turno_enemigo()

func _ejecutar_turno_enemigo() -> void:
	for enemigo in enemigos:
		if not is_instance_valid(enemigo) or enemigo.hp <= 0:
			continue
		await _ejecutar_accion_enemigo(enemigo)
		if _verificar_fin_combate():
			return
	
	if not _verificar_fin_combate():
		_iniciar_turno_jugador()

func _ejecutar_accion_enemigo(enemigo: Enemy) -> void:
	# placeholder: acá se ejecuta la intención guardada del enemigo (fase futura)
	enemigo_actuo.emit(enemigo)
	await get_tree().create_timer(0.6).timeout  # tiempo para que la UI anime el ataque

func _verificar_fin_combate() -> bool:
	if player.hp <= 0:
		estado = Estado.DERROTA
		combate_terminado.emit(false)
		return true

	var alguno_vivo := false
	for enemigo in enemigos:
		if is_instance_valid(enemigo) and enemigo.hp > 0:
			alguno_vivo = true
			break

	if not alguno_vivo:
		estado = Estado.VICTORIA
		combate_terminado.emit(true)
		return true
	return false
