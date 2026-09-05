extends Button

@onready var fondo = $Fondo
@onready var sprite = $Sprite
@onready var nombre = $Nombre

var fondo_normal = preload("res://Assets/BckGrnd/paperallborder.png")
var fondo_hover = preload("res://Assets/BckGrnd/paperallborderrojo.png")

var sprite_normal = preload("res://Assets/ChArt/caelius de ego.png")
var sprite_hover = preload("res://Assets/BttlSprit/fause.png")

var color_nombre_normal = Color("#906502")
var color_nombre_hover = Color("#500009")


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered():
	fondo.texture = fondo_hover
	sprite.texture = sprite_hover
	nombre.modulate = color_nombre_hover


func _on_mouse_exited():
	fondo.texture = fondo_normal
	sprite.texture = sprite_normal
	nombre.modulate = color_nombre_normal
