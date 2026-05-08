extends Node2D

@onready var player = $CanvasLayer/player
@onready var enemy = $CanvasLayer/enemy

# LOOP
func _process(_delta):

	handle_turn(player, enemy)
	handle_turn(enemy, player)

# TURNOS
func handle_turn(atacante, defensor):

	if atacante == null or defensor == null:
		return

	if atacante.hp <= 0:
		return

	if defensor.hp <= 0:
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

	# INMUNE
	if defensor.inmune:
		print(defensor.nombre + " es inmune!")
		return 0

	# NUEVA FORMULA
	var daño_base = atacante.daño * atacante.bonus_daño
	var defensa_base = defensor.defensa * defensor.bonus_defensa

	var daño = (daño_base * 1.4) - (defensa_base * 0.5)

	# VARIACIÓN
	var variacion = randf_range(0.9, 1.1)

	daño *= variacion

	# MINIMO
	daño = max(int(daño), 1)

	return daño

# EFECTOS
func aplicar_efectos(atacante, defensor, daño):

	# RECIBIR DAÑO
	if defensor.has_method("recibir_daño"):
		defensor.recibir_daño(daño)

	# ROBO VIDA
	if atacante.robo_vida:

		atacante.hp += daño

		atacante.hp = min(atacante.hp, atacante.max_hp)

		atacante.actualizar_barra_vida()

		print("Robo de vida!")

	# DOBLE GOLPE
	if atacante.doble_golpe:

		print("Doble impacto!")

		if defensor.has_method("recibir_daño"):
			defensor.recibir_daño(daño)

# ATAQUE
func atacar(atacante, defensor):

	animar_ataque(atacante)

	var daño_final = calcular_daño(atacante, defensor)

	if daño_final <= 0:
		return

	aplicar_efectos(atacante, defensor, daño_final)

	print(
		atacante.nombre +
		" golpea a " +
		defensor.nombre +
		" por " +
		str(daño_final)
	)

	# FLASH
	defensor.modulate = Color(0.747, 0.0, 0.169)

	await get_tree().create_timer(0.1).timeout

	defensor.modulate = Color(1,1,1)

# ANIMACIÓN
func animar_ataque(atacante):

	var tween = create_tween()

	var posicion_original = atacante.position

	var distancia = 40

	var posicion_ataque

	if atacante == player:
		posicion_ataque = posicion_original + Vector2(distancia,0)

	else:
		posicion_ataque = posicion_original + Vector2(-distancia,0)

	tween.tween_property(
		atacante,
		"position",
		posicion_ataque,
		0.1
	)

	tween.tween_property(
		atacante,
		"position",
		posicion_original,
		0.1
	)
