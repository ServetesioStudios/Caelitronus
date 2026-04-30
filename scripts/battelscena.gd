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

# ATAQUE
func atacar(atacante, defensor):

	# ANIMACIÓN
	animar_ataque(atacante)

	# ESQUIVE
	var chance = randi() % 100
	if chance < defensor.esquive:
		print(defensor.nombre + " esquivó!")
		return

	# DAÑO
	var daño_final = atacante.daño - defensor.defensa
	daño_final = max(daño_final, 1)

	defensor.hp -= daño_final

	print(atacante.nombre + " golpea a " + defensor.nombre + " por " + str(daño_final))

	# IMPACTO VISUAL
	defensor.modulate = Color(0.747, 0.0, 0.169, 1.0)
	await get_tree().create_timer(0.1).timeout
	defensor.modulate = Color(1, 1, 1)

	# MUERTE
	if defensor.hp <= 0:
		print(defensor.nombre + " fue derrotado")

# ANIMACIÓN DE ATAQUE
func animar_ataque(atacante):

	var tween = create_tween()

	var posicion_original = atacante.position

	var distancia = 40

	var posicion_ataque

	# Player → derecha
	if atacante == player:
		posicion_ataque = posicion_original + Vector2(distancia, 0)

	# Enemy → izquierda
	else:
		posicion_ataque = posicion_original + Vector2(-distancia, 0)

	# Ir hacia adelante
	tween.tween_property(atacante, "position", posicion_ataque, 0.1)

	# Volver
	tween.tween_property(atacante, "position", posicion_original, 0.1) 
