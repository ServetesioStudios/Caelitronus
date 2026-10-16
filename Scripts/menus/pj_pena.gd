extends Button

@onready var Fondo = $Fondo
@onready var Sprite = $Sprite
@onready var nombre = $Nombre

var Fondo_normal = preload("res://Assets/BckGrnd/paperallborder.png")
var Fondo_hover = preload("res://Assets/BckGrnd/paperallborderrojo.png")

var Sprite_normal = preload("res://Assets/ChArt/caelius de pena.png")
var Sprite_hover = preload("res://Assets/BttlSprit/fause.png")

var color_nombre_normal = Color("#906502")
var color_nombre_hover = Color("#500009")

func  _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
func _on_mouse_entered():
	Fondo.texture = Fondo_hover
	Sprite.texture = Sprite_hover
	nombre.modulate = color_nombre_hover
	
func _on_mouse_exited():
	Fondo.texture = Fondo_normal
	Sprite.texture = Sprite_normal
	nombre.modulate = color_nombre_normal
