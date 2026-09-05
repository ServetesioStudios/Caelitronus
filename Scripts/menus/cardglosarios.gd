extends TextureRect

@onready var sprite = $TextureRect
@onready var button = $Button

var sprite_normal
var sprites_hover: Array[Texture2D] = []


func _ready():
	match name:
		"Caelius":
			sprite_normal = preload("res://Assets/ChArt/caelius de ira.png")
			sprites_hover = [
				preload("res://Assets/BttlSprit/fause.png")
			]

		"Papa":
			sprite_normal = preload("res://Assets/ChArt/el papa.png")
			sprites_hover = [
				preload("res://Assets/ChArt/trono.png")
			]
			
		"Monja":
			sprite_normal = preload("res://Assets/ChArt/monjasenta.png")
			sprites_hover = [
				preload("res://Assets/ChArt/la monja.png")
			]
		
		"Monaquillo":
			sprite_normal = preload("res://Assets/ChArt/los monaquillo.png")
			sprites_hover = [
				preload("res://Assets/BttlSprit/almamonaquillos.png")
			]
			
		"Espina":
			sprite_normal = preload("res://Assets/ChArt/padre espina.png")
			sprites_hover = [
				preload("res://Assets/BttlSprit/Kamathra.png")
			]
			
		"Serpico":
			sprite_normal = preload("res://Assets/ChArt/Obispo Serpico.png")
			sprites_hover = [
				preload("res://Assets/BttlSprit/vahruksha.png")
			]
			
		"Eirene":
			sprite_normal = preload("res://Assets/ChArt/Eirene Koryphé.png")
			sprites_hover = [
				preload("res://Assets/BttlSprit/Artemisia.png")
			]
			
		"Corvus":
			sprite_normal = preload("res://Assets/ChArt/Fray Corvus.png")
			sprites_hover = [
				preload("res://Assets/BttlSprit/Nzolukaya.png")
			]
		
		"Galaad":
			sprite_normal = preload("res://Assets/ChArt/galaad.png")
			sprites_hover = [
				preload("res://Assets/BttlSprit/Eliadran.png")
			]
			
		"Kapparah":
			sprite_normal = preload("res://Assets/ChArt/Kapparah.png")
			sprites_hover = [
				preload("res://Assets/BttlSprit/Tzafiel.png")
			]
			
		"Devotio":
			sprite_normal = preload("res://Assets/ChArt/Devotio.png")
			sprites_hover = [
				preload("res://Assets/ChArt/los monaquillo.png")
			]
			
		"Trono":
			sprite_normal = preload("res://Assets/ChArt/trono.png")
			sprites_hover = [
				preload("res://Assets/ChArt/monjasenta.png"),
				preload("res://Assets/ChArt/el papa.png")
			]
			
		"Alma":
			sprite_normal = preload("res://Assets/BttlSprit/alma.png")
			sprites_hover = [
				preload("res://Assets/BttlSprit/fause.png"),
				preload("res://Assets/BttlSprit/almamonaquillos.png"),
				preload("res://Assets/BttlSprit/Kamathra.png"),
				preload("res://Assets/BttlSprit/vahruksha.png"),
				preload("res://Assets/BttlSprit/Artemisia.png"),
				preload("res://Assets/BttlSprit/Nzolukaya.png"),
				preload("res://Assets/BttlSprit/Eliadran.png"),
				preload("res://Assets/BttlSprit/Tzafiel.png")
			]


	sprite.texture = sprite_normal

	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered():
	if sprites_hover.size() > 0:
		sprite.texture = sprites_hover.pick_random()


func _on_mouse_exited():
	sprite.texture = sprite_normal
