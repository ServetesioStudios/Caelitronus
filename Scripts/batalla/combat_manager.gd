class_name CombatManager
extends Node

var player: Player

signal turno_jugador_iniciado
signal turno_enemigo_iniciado
signal enemigo_actuo(enemigo: Enemy)
signal combate_terminado(victoria: bool)
signal energia_actualizada(actual: int, maxima: int)
signal intencion_actualizada(enemigo: Enemy)

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
	
	for enemigo in enemigos:
		if is_instance_valid(enemigo) and enemigo.hp > 0:
			enemigo.decidir_intencion()
			intencion_actualizada.emit(enemigo)
	
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
	enemigo_actuo.emit(enemigo)
	
	match enemigo.intencion_actual.tipo:
		IntentData.Tipo.ATACAR:
			if is_instance_valid(player) and player.hp > 0:
				var daño = _calcular_daño_enemigo(enemigo, player)
				if daño > 0:
					player.recibir_daño(daño)
					
		IntentData.Tipo.DEFENDER:
			enemigo.bloqueo += enemigo.intencion_actual.valor
		
		IntentData.Tipo.HABILIDAD:
			enemigo.activar_habilidad()
			
	await get_tree().create_timer(0.6).timeout  # tiempo para que la UI anime el ataque

func _calcular_daño_enemigo(atacante: CombatEntity, defensor: CombatEntity) -> int:
	var chance = randi() % 100
	if chance < defensor.esquive or defensor.inmune:
		print("chance %d" %chance)
		return 0
	
	var daño_base = atacante.daño * atacante.bonus_daño
	print("daño base = %f + bonus %f" %
	[atacante.daño, atacante.bonus_daño])
	
	var defensa_base = defensor.defensa * defensor.bonus_defensa
	
	var reduccion = defensa_base / (defensa_base + 10.0)
	var daño = daño_base * (1.0 - reduccion)
	
	var variacion = randf_range(0.85, 1.05)
	daño *= variacion
	print("daño atacante %f" %daño)
	return max(int(daño), 1)
		
	
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

func es_turno_jugador() -> bool:
	return estado == Estado.TURNO_JUGADOR

func verificar_fin_combate() -> bool:
	return _verificar_fin_combate()
