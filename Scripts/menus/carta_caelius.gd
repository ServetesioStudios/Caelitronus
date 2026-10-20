extends Button

@export_group("Imagenes del Caelius")
@export var textura_personaje: Texture2D
@export var textura_alma: Texture2D

@onready var fondo: TextureRect = $Fondo
@onready var sprite: TextureRect = $Sprite
@onready var nombre: Label = $Nombre

const FONDO_NORMAL = preload("res://Assets/BckGrnd/paperallborder.png")
const FONDO_HOVER = preload("res://Assets/BckGrnd/paperallborderrojo.png")

const COLOR_NOMBRE_NORMAL = Color("#906502")
const COLOR_NOMBRE_HOVER = Color("#500009")


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	mostrar_personaje_normal()


func _on_mouse_entered() -> void:
	fondo.texture = FONDO_HOVER
	sprite.texture = textura_alma
	nombre.modulate = COLOR_NOMBRE_HOVER


func _on_mouse_exited() -> void:
	mostrar_personaje_normal()


func mostrar_personaje_normal() -> void:
	fondo.texture = FONDO_NORMAL
	sprite.texture = textura_personaje
	nombre.modulate = COLOR_NOMBRE_NORMAL
