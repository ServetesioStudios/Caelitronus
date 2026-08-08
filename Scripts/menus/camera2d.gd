extends Camera2D

@export var distancia: float = 25.0
@export var velocidad: float = 3.5
@export var pausa_min: float = 0.05
@export var pausa_max: float = 0.15

var origen: Vector2
var destino: Vector2

var esperando := false
var tiempo_pausa := 0.0

var ultimo_indice := -1

var posiciones := [
	Vector2( 0.8, -0.3), # ↗
	Vector2( 0.9,  0.8), # ↘
	Vector2( 0.3, -1.0), # ↖
	Vector2(-0.2, -1.0), # ↙

	Vector2(-0.9, -0.4),
	Vector2(-1.0,  0.2),
	Vector2(-0.7,  0.8),
	Vector2(-0.3,  1.0),

	Vector2( 0.2,  1.0),
	Vector2( 0.8,  0.7),
	Vector2( 1.0,  0.3),
	Vector2( 0.6, -0.9),

	Vector2( 1.2,  0.0),
	Vector2(-1.2,  0.0),
	Vector2( 0.0, -1.2),
	Vector2( 0.0,  1.2)
]

func _ready():
	randomize()

	origen = position

	elegir_nuevo_destino()


func _process(delta):

	if esperando:
		tiempo_pausa -= delta

		if tiempo_pausa <= 0:
			esperando = false
			elegir_nuevo_destino()

		return

	position = position.move_toward(destino, velocidad * 60 * delta)

	if position.distance_to(destino) < 1.0:
		esperando = true
		tiempo_pausa = randf_range(pausa_min, pausa_max)


func elegir_nuevo_destino():

	var indice = randi() % posiciones.size()

	while indice == ultimo_indice:
		indice = randi() % posiciones.size()

	ultimo_indice = indice

	var dir = posiciones[indice].normalized()

	var distancia_real = randf_range(distancia * 0.5, distancia)

	destino = origen + dir * distancia_real
