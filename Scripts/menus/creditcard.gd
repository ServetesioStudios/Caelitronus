extends TextureRect

@onready var sprite = $TextureRect
@onready var button = $Link
@onready var label = $Label

var sprite_normal
var sprite_hover

var texto_normal = ""
var texto_hover = ""


func _ready():
	print("Personaje detectado: ", name)

	match name:
		"Anto":
			sprite_normal = preload("res://Assets/credit/anto.png")
			sprite_hover = preload("res://Assets/ChArt/monjasenta.png")

		"Esperanza":
			sprite_normal = preload("res://Assets/credit/espe.png")
			sprite_hover = preload("res://Assets/ChArt/Eirene Koryphé.png")

		"matute":
			sprite_normal = preload("res://Assets/credit/matu.png")
			sprite_hover = preload("res://Assets/ChArt/sintax.png")

		"Javier":
			sprite_normal = preload("res://Assets/credit/Javier.png")
			texto_normal = "Javier Juarez"
			texto_hover = "Programador"

		"Matias":
			sprite_normal = preload("res://Assets/credit/matias.png")
			texto_normal = "Matias Diaz"
			texto_hover = "Programador"

		"Uriel":
			sprite_normal = preload("res://Assets/credit/uri.png")
			texto_normal = "Uriel Lara"
			texto_hover = "Programador"
		
		"Matute":
			sprite_normal = preload("res://Assets/credit/matu.png")
			texto_normal = "Matute"
			texto_hover = "Game Desing"


	sprite.texture = sprite_normal

	if texto_normal != "":
		label.text = texto_normal

	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered():
	if texto_hover != "":
		label.text = texto_hover
	else:
		sprite.texture = sprite_hover


func _on_mouse_exited():
	if texto_normal != "":
		label.text = texto_normal
	else:
		sprite.texture = sprite_normal
