extends AnimatedSprite2D

@export var posiciones: Array[Vector2] = [
	Vector2(200, 160),
	Vector2(1200, 160),
	Vector2(150, 560),
	Vector2(1100, 560)
]

@export var tiempo_espera: float = 2.0

var posicion_actual := -1

func _ready():
	randomize()
	
	if sprite_frames.has_animation("aparicion"):
		animation_finished.connect(_cuando_termina_aparicion)
		
		cambiar_posicion()
		
		frame = 5
		
		play_backwards("aparicion")
		
	else: 
		play("default")
		
func _cuando_termina_aparicion():
	if frame == 0:
		play("aparicion")
		
	elif frame == 5:
		espera_y_cambiar()
		
func espera_y_cambiar():
	await get_tree().create_timer(tiempo_espera).timeout
	
	cambiar_posicion()
	
	frame = 5
	
	play_backwards("aparicion")
	
func cambiar_posicion():
	var nueva_posicion := randi() % posiciones.size()
	
	while nueva_posicion == posicion_actual and posiciones.size() > 1:
		nueva_posicion = randi() % posiciones.size()
		
	posicion_actual = nueva_posicion
	position = posiciones[posicion_actual]
	
	if posicion_actual == 0 or posicion_actual == 1:
		flip_v = true
	else:
		flip_v = false
