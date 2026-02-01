extends Control

@onready var hover_sound = $HoverSound
var glosariotexto = ConfigFile.new()
var progreso = ConfigFile.new()
var glosarioid


func _ready():
	for button in get_tree().get_nodes_in_group("GlosarioButton"):
		button.pressed.connect(_on_button_pressed.bind(button.get_parent().name))
	var err = progreso.load("res://cfg/progreso.cfg")
	if err == OK:
		var caelius = progreso.get_value("Caelius","tipo")
		if caelius != "":
			match caelius:
				"ego":
					$General/ScrollContainerPersonajes/Personajes/Caelius/TextureRect.texture = load("res://assets/ChArt/caelius de ego.png")
				"ira":
					$General/ScrollContainerPersonajes/Personajes/Caelius/TextureRect.texture = load("res://assets/ChArt/caelius de ira.png")
				"pena":
					$General/ScrollContainerPersonajes/Personajes/Caelius/TextureRect.texture = load("res://assets/ChArt/caelius de pena.png")
		else:
			ocultar("Caelius")
			$General/ScrollContainerMaldiciones/Maldiciones/Reves/TextureRect.modulate = Color()
			$General/ScrollContainerMaldiciones/Maldiciones/Reves/Label.text = "???"
			$General/ScrollContainerMaldiciones/Maldiciones/Reves/Button.disabled = true
		if progreso.get_value("Jefes","espina") == 0:
			ocultar("Espina")
		if progreso.get_value("Jefes","serpico") == 0:
			ocultar("Serpico")
		if progreso.get_value("Jefes","theresa") == 0:
			ocultar("Theresa")
		if progreso.get_value("Jefes","corvus") == 0:
			ocultar("Corvus")
		if progreso.get_value("Jefes","galaad") == 0:
			ocultar("Galaad")
		if progreso.get_value("Jefes","kapparah") == 0:
			ocultar("Kapparah")
			
		
func ocultar(nombre):
	$General/ScrollContainerPersonajes/Personajes.get_node(nombre + "/TextureRect").modulate = Color()
	$General/ScrollContainerPersonajes/Personajes.get_node(nombre + "/Label").text = "???"
	$General/ScrollContainerPersonajes/Personajes.get_node(nombre + "/Button").disabled = true

func _on_hover() -> void:
	if hover_sound.playing:
		hover_sound.stop()
	hover_sound.play()
	

func _on_atras_pressed() -> void:
	if $Detalle.visible:
		$Detalle.hide()
		$General.show()
		$Glosario.text = "Glosario"
	else:
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")


func _on_button_mouse_entered() -> void:
	hover_sound.play()


func _on_button_der_pressed() -> void:
	if $General/Tipo.text == "Personajes":
		$General/ButtonIzq.show()
		$General/ScrollContainerPersonajes.hide()
		$General/ScrollContainerMaldiciones.show()
		$General/Tipo.text = "Maldiciones"
	else:
		$General/ButtonDer.hide()
		$General/ScrollContainerMaldiciones.hide()
		$General/ScrollContainerPoderes.show()
		$General/Tipo.text = "Poderes del Mundo"


func _on_button_izq_pressed() -> void:
	if $General/Tipo.text == "Maldiciones":
		$General/ButtonIzq.hide()
		$General/ScrollContainerMaldiciones.hide()
		$General/ScrollContainerPersonajes.show()
		$General/Tipo.text = "Personajes"
	else:
		$General/ButtonDer.show()
		$General/ScrollContainerPoderes.hide()
		$General/ScrollContainerMaldiciones.show()
		$General/Tipo.text = "Maldiciones"


func _on_button_pressed(id) -> void:
	var err = glosariotexto.load("res://cfg/glosario.cfg")
	if err != OK:
		return
	glosarioid = id
	$General.hide()
	if id == "Devotio" or id == "Reves" or id == "Trono" or id == "Alma" or id == "MonjaPoder":
		$Detalle/Descripcion/texto.text = "Concepto"
		$Detalle/Descripcion.disabled = true
		$Detalle/Alma.hide()
		$Detalle/Religion.hide()
		$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(id,"descripcion")
		if id == "Devotio" or id == "Reves":
			$Detalle/Imagen/TextureRect.texture = $General/ScrollContainerMaldiciones/Maldiciones.get_node(glosarioid + "/TextureRect").texture
		else:
			$Detalle/Imagen/TextureRect.texture = $General/ScrollContainerPoderes/Poderes.get_node(glosarioid + "/TextureRect").texture
	else:
		$Detalle/Descripcion/texto.text = "Historia"
		$Detalle/Alma.show()
		$Detalle/Religion.show()
		$Detalle/Descripcion.emit_signal("pressed")
	$Glosario.text = glosariotexto.get_value(id,"nombre")
	$Detalle.show()

func _on_descripcion_pressed() -> void:
	$Detalle/Descripcion.disabled = true
	$Detalle/Religion.disabled = false
	$Detalle/Alma.disabled = false
	if glosarioid == "Caelius":
		match progreso.get_value("Caelius","tipo"):
			"ego":
				$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"descripcionego")
			"ira":
				$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"descripcionira")
			"pena":
				$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"descripcionpena")
	else:
		$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"descripcion")
	$Detalle/Imagen/TextureRect.texture = $General/ScrollContainerPersonajes/Personajes.get_node(glosarioid + "/TextureRect").texture


func _on_religion_pressed() -> void:
	$Detalle/Religion.disabled = true
	$Detalle/Descripcion.disabled = false
	$Detalle/Alma.disabled = false
	$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"religion")
	$Detalle/Imagen/TextureRect.texture = $General/ScrollContainerPersonajes/Personajes.get_node(glosarioid + "/TextureRect").texture


func _on_alma_pressed() -> void:
	$Detalle/Alma.disabled = true
	$Detalle/Descripcion.disabled = false
	$Detalle/Religion.disabled = false
	if glosarioid == "Caelius":
		match progreso.get_value("Caelius","tipo"):
			"ego":
				$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"almaego")
			"ira":
				$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"almaira")
			"pena":
				$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"almapena")
		$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/fause.png")
	else:
		$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"alma")
	match glosarioid:
		"Espina":
			$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Kamathra.png")
		"Serpico":
			$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/vahruksha.png")
		"Corvus":
			$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Nzolukaya.png")
		"Galaad":
			$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Eliadran.png")
		"Kapparah":
			$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Tzafiel.png")
