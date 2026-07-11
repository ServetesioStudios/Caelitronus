class_name CombatManager
extends Node

var player: Player

signal turno_jugador_iniciado
signal turno_enemigo_iniciado
signal enemigo_actuo(enemigo: Enemy)
signal combate_terminado(victoria: bool)
signal energia_actualizada(actual: int, maxima: int)
signal accion_enemigo_realizada(enemigo: Enemy, descripcion: String)

enum Estado { INICIO, TURNO_JUGADOR, TURNO_ENEMIGO, VICTORIA, DERROTA }
var estado: Estado = Estado.INICIO
var enemigos: Array[Enemy] = []

func iniciar_combate(p: CombatEntity, e: Array[Enemy]) -> void:
	player = p
	enemigos = e
	player.resetear_energia()
	
	for enemigo in enemigos:
		if is_instance_valid(enemigo) and enemigo.hp > 0:
			_actualizar_intencion(enemigo)
			
	_iniciar_turno_jugador()


func es_turno_jugador() -> bool:
	if not is_instance_valid(player) or player.hp <= 0:
		return estado == Estado.DERROTA
	return estado == Estado.TURNO_JUGADOR
	
func _iniciar_turno_jugador() -> void:
	estado = Estado.TURNO_JUGADOR
	player.procesar_estados()
	if _verificar_fin_combate():
		return
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

		enemigo.procesar_estados()
		if enemigo.hp <= 0:
			if _verificar_fin_combate():
				return
			continue
		await _ejecutar_accion_enemigo(enemigo)
		if _verificar_fin_combate():
			return
		_actualizar_intencion(enemigo)
	if not _verificar_fin_combate():
		_iniciar_turno_jugador()

func _actualizar_intencion(enemigo: Enemy) -> void:
	enemigo.decidir_intencion()
	if enemigo.intencion_actual.tipo == IntentData.Tipo.ATACAR:
		enemigo.intencion_actual.valor = _calcular_daño_predicho(enemigo, player)
	enemigo.actualizar_intencion_ui()
	
func _ejecutar_accion_enemigo(enemigo: Enemy) -> void:
	enemigo_actuo.emit(enemigo)
	var descripcion := ""


	print(
		"ACCION:",
		IntentData.Tipo.keys()[enemigo.intencion_actual.tipo],
		" robo:",
		enemigo.robo_vida
	)


	match enemigo.intencion_actual.tipo:
		IntentData.Tipo.ATACAR:
			if is_instance_valid(player) and player.hp > 0:
				var daño = _calcular_daño_enemigo(enemigo, player)
				if daño > 0:
					player.recibir_daño(daño)
					descripcion = "%s ataca e inflige %d de daño" % [enemigo.nombre, daño]
					if enemigo.robo_vida:
						var vida_robada = int(daño * enemigo.porcentaje_robo_vida)
						enemigo.hp = min(enemigo.hp + vida_robada, enemigo.max_hp)
						enemigo.actualizar_barra_vida()
						descripcion += " y roba %d de vida" % vida_robada
				else:
					descripcion = "%s atacó, pero fue esquivado" % enemigo.nombre
				enemigo.al_atacar()
		IntentData.Tipo.DEFENDER:
			enemigo.bloqueo += enemigo.intencion_actual.valor
			descripcion = "%s se defiende y gana %d de bloqueo" % [enemigo.nombre, enemigo.intencion_actual.valor]
		IntentData.Tipo.HABILIDAD:
			enemigo.activar_habilidad()
			descripcion = "%s usa %s" % [enemigo.nombre, enemigo.habilidad_nombre]
			enemigo.aplicar_efecto_habilidad_a_objetivo(player) 
			
	accion_enemigo_realizada.emit(enemigo, descripcion)
	await get_tree().create_timer(0.6).timeout
	
	
func _calcular_daño_predicho(atacante: CombatEntity, defensor: CombatEntity) -> int:
	var daño_base = atacante.daño * atacante.bonus_daño
	var defensa_base = defensor.defensa * defensor.bonus_defensa
	var reduccion = defensa_base / (defensa_base + 10.0)
	var daño = daño_base * (1.0 - reduccion)
	return max(int(daño), 1)
	
func _calcular_daño_enemigo(atacante: CombatEntity, defensor: CombatEntity) -> int:
	var chance = randi() % 100
	if chance < defensor.esquive_efectivo() or defensor.inmune:
		return 0
	
	var daño_base = atacante.daño * atacante.bonus_daño
	var defensa_base = defensor.defensa * defensor.bonus_defensa
	
	var reduccion = defensa_base / (defensa_base + 10.0)
	var daño = daño_base * (1.0 - reduccion)
	
	var variacion = randf_range(0.85, 1.05)
	daño *= variacion
	return max(int(daño), 1)


func verificar_fin_combate() -> bool:
	return _verificar_fin_combate()

func _verificar_fin_combate() -> bool:
	if is_instance_valid(player) and player.hp <= 0:
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
