extends Control

@onready var hover_sound = $HoverSound

func _ready():
	for button in get_tree().get_nodes_in_group("LinkPersonal"):
		button.pressed.connect(_on_link_pressed.bind(button.get_parent().name))

	# SOLO esto se agrega ↓
	$ButtonIzq.mouse_entered.connect(_on_hover)
	$ButtonDer.mouse_entered.connect(_on_hover)

func _on_hover() -> void:
	if hover_sound.playing:
		hover_sound.stop()
	hover_sound.play()

func _on_atras_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/menus/menu_principal.tscn")
	queue_free()

func _on_links_pressed() -> void:
	OS.shell_open("https://linktr.ee/ServentesioStudios")

func _on_button_der_pressed() -> void:
	$Tipo.text = "ACTORES \nDE VOZ"
	$ButtonDer.hide()
	$Desarrolladores.hide()
	$Voces.show()
	$ButtonIzq.show()

func _on_button_izq_pressed() -> void:
	$Tipo.text = "DESARROLLADORES"
	$ButtonIzq.hide()
	$Voces.hide()
	$ButtonDer.show()
	$Desarrolladores.show()

# ⚠️ ESTA FUNCIÓN NO SE TOCA
func _on_link_pressed(id) -> void:
	match id:
		"Javier":
			OS.shell_open("https://www.linkedin.com/in/javier-david-juarez/")
		"Matias":
			OS.shell_open("https://tredarnos.itch.io/")
		"Adrian":
			OS.shell_open("https://www.linkedin.com/in/adrianrobertobriosso/")
		"Matute":
			OS.shell_open("https://linktr.ee/Matute.fk2")
		"Uriel":
			OS.shell_open("https://www.linkedin.com/in/urielara")
		"Anto":
			OS.shell_open("https://linktr.ee/ServentesioStudios")
		"Lucio":
			OS.shell_open("https://linktr.ee/ServentesioStudios")
		"Thiago":
			OS.shell_open("https://linktr.ee/ServentesioStudios")
		"Joaquin":
			OS.shell_open("https://linktr.ee/ServentesioStudios")

func _on_link_mouse_entered() -> void:
	hover_sound.play()
