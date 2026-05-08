extends Node2D

@onready var player = $CanvasLayer/player
@onready var enemy = $CanvasLayer/enemy

# LOOP PRINCIPAL
func _process(_delta):
	handle_turn(player, enemy)
	handle_turn(enemy, player)

# CONTROL DE TURNOS
func handle_turn(atacante, defensor):
	if atacante == null or defensor == null:
		return

	if atacante.puede_atacar():
		atacar(atacante, defensor)
		atacante.reiniciar_tiempo()

# CALCULAR DAÑO
func calcular_daño(atacante, defensor):

	# ESQUIVE
	var chance = randi() % 100
	if chance < defensor.esquive:
		print(defensor.nombre + " esquivó!")
		return 0

	# INMUNIDAD
	if defensor.inmune:
		print(defensor.nombre + " es inmune!")
		return 0

	# DAÑO BASE + BONUS
	var daño_base = atacante.daño * atacante.bonus_daño
	var defensa_base = defensor.defensa * defensor.bonus_defensa

	var daño = daño_base - defensa_base

	# VARIACIÓN
	var variacion = randf_range(0.9, 1.1)
	daño *= variacion

	# MÍNIMO
	daño = max(int(daño), 1)

	return daño

# APLICAR EFECTOS
func aplicar_efectos(atacante, defensor, daño):

	# INMUNIDAD FINAL
	if defensor.inmune:
		return

	# DAÑO CORRECTO
	if defensor.has_method("recibir_daño"):
		defensor.recibir_daño(daño)
		
	else:
		defensor.hp -= daño
		if defensor.has_method("actualizar_barra_vida"):
			defensor.actualizar_barra_vida()

	# ROBO DE VIDA (PENA)
	if atacante.robo_vida:
		atacante.hp += daño
		atacante.hp = min(atacante.hp, atacante.max_hp)
		atacante.actualizar_barra_vida()
		print("Robo de vida!")

	# DOBLE GOLPE (EGO)
	if atacante.doble_golpe:
		print("Doble impacto!")

		if defensor.has_method("recibir_daño"):
			defensor.recibir_daño(daño)
		else:
			defensor.hp -= daño
			if defensor.has_method("actualizar_barra_vida"):
				defensor.actualizar_barra_vida()

# ATAQUE COMPLETO
func atacar(atacante, defensor):

	# ANIMACIÓN
	animar_ataque(atacante)

	# CALCULAR DAÑO
	var daño_final = calcular_daño(atacante, defensor)

	# SI FALLA
	if daño_final <= 0:
		print("El ataque no tuvo efecto")
		return

	# APLICAR EFECTOS
	aplicar_efectos(atacante, defensor, daño_final)

	#INFORMACION
	print(atacante.nombre + " golpea a " + defensor.nombre + " por " + str(daño_final))

	# IMPACTO VISUAL
	defensor.modulate = Color(0.747, 0.0, 0.169, 1.0)
	await get_tree().create_timer(0.1).timeout
	defensor.modulate = Color(1, 1, 1)

	# MUERTE (seguridad)
	if defensor.hp <= 0:
		print(defensor.nombre + " fue derrotado")

# ANIMACIÓN DE ATAQUE
func animar_ataque(atacante):

	var tween = create_tween()

	var posicion_original = atacante.position
	var distancia = 40
	var posicion_ataque

	if atacante == player:
		posicion_ataque = posicion_original + Vector2(distancia, 0)
	else:
		posicion_ataque = posicion_original + Vector2(-distancia, 0)

	tween.tween_property(atacante, "position", posicion_ataque, 0.1)
	tween.tween_property(atacante, "position", posicion_original, 0.1)
