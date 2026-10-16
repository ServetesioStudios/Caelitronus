extends AnimatedSprite2D

@export var posiciones: Array[Vector2] =[
	Vector2(220, 100),
	Vector2(1000, 300),
	Vector2(1100, 200),
	Vector2(1200, 50),
	Vector2(220, 620),
	Vector2(1100, 620),
	Vector2(550, 190)
]

var  posicion_actual := -1

func _ready(): 
	randomize()
	
	animation_finished.connect(_cuando_termina)
	
	cambiar_posicion()
	
	frame = 0
	play("exolocion")
	
func _cuando_termina():
	cambiar_posicion()
	
	frame = 0
	play("exolocion")
	
func cambiar_posicion():
	var nueva_posicion := randi() % posiciones.size()
	
	while nueva_posicion == posicion_actual and posiciones.size() > 1:
		nueva_posicion = randi() % posiciones.size()
		
	posicion_actual = nueva_posicion
	position = posiciones[posicion_actual]
