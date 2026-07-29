extends Control

@onready var hover_sound = $HoverSound
var glosariotexto = ConfigFile.new()
#var progreso = ConfigFile.new()
var glosarioid: String = ""


func _ready():
	for button in get_tree().get_nodes_in_group("GlosarioButton"):
		button.pressed.connect(_on_button_pressed.bind(button.get_parent().name))
		
	if GameManager.player_data != null:
		match GameManager.player_data.tipo_caelius:
				GameManager.TipoCaelius.EGO:
					$Panel/General/ScrollContainerPersonajes/Personajes/Caelius/TextureRect.texture = load("res://assets/ChArt/caelius de ego.png")
				GameManager.TipoCaelius.IRA:
					$Panel/General/ScrollContainerPersonajes/Personajes/Caelius/TextureRect.texture = load("res://assets/ChArt/caelius de ira.png")
				GameManager.TipoCaelius.PENA:
					$Panel/General/ScrollContainerPersonajes/Personajes/Caelius/TextureRect.texture = load("res://assets/ChArt/caelius de pena.png")
	else:
		ocultar("Caelius")
		$Panel/General/ScrollContainerMaldiciones/Maldiciones/Reves/TextureRect.modulate = Color()
		$Panel/General/ScrollContainerMaldiciones/Maldiciones/Reves/Label.text = "???"
		$Panel/General/ScrollContainerMaldiciones/Maldiciones/Reves/Button.disabled = true
		$Panel/General/ScrollContainerMaldiciones/Maldiciones/Reves/Button.set_block_signals(1)

	for jefe_nombre in GameManager.Jefe.keys():
		var jefe_id = GameManager.Jefe[jefe_nombre]
		if not GameManager.es_jefe_derrotado(jefe_id):
			ocultar(jefe_nombre.capitalize())	
		
func ocultar(nombre):
	$Panel/General/ScrollContainerPersonajes/Personajes.get_node(nombre + "/TextureRect").modulate = Color()
	$Panel/General/ScrollContainerPersonajes/Personajes.get_node(nombre + "/Label").text = "???"
	$Panel/General/ScrollContainerPersonajes/Personajes.get_node(nombre + "/Button").disabled = true
	$Panel/General/ScrollContainerPersonajes/Personajes.get_node(nombre + "/Button").set_block_signals(1)


func _on_atras_pressed() -> void:
	if $Panel/Detalle.visible:
		$Panel/Detalle.hide()
		$Panel/General.show()
		$Panel/Glosario.text = "Glosario"
	else:
		queue_free()


func _on_button_mouse_entered() -> void:
	if hover_sound.playing == true:
		hover_sound.stop()
	hover_sound.play()


func _on_button_der_pressed() -> void:
	if $Panel/General/Tipo.text == "Personajes":
		$Panel/General/ButtonIzq.show()
		$Panel/General/ScrollContainerPersonajes.hide()
		$Panel/General/ScrollContainerMaldiciones.show()
		$Panel/General/Tipo.text = "Maldiciones"
	else:
		$Panel/General/ButtonDer.hide()
		$Panel/General/ScrollContainerMaldiciones.hide()
		$Panel/General/ScrollContainerPoderes.show()
		$Panel/General/Tipo.text = "Poderes del Mundo"


func _on_button_izq_pressed() -> void:
	if $Panel/General/Tipo.text == "Maldiciones":
		$Panel/General/ButtonIzq.hide()
		$Panel/General/ScrollContainerMaldiciones.hide()
		$Panel/General/ScrollContainerPersonajes.show()
		$Panel/General/Tipo.text = "Personajes"
	else:
		$Panel/General/ButtonDer.show()
		$Panel/General/ScrollContainerPoderes.hide()
		$Panel/General/ScrollContainerMaldiciones.show()
		$Panel/General/Tipo.text = "Maldiciones"


func _on_button_pressed(id) -> void:
	var err = glosariotexto.load("res://Data/text/glosario.cfg")
	if err != OK:
		return
	glosarioid = id
	$Panel/General.hide()
	if id == "Devotio" or id == "Reves" or id == "Trono" or id == "Alma" or id == "MonjaPoder":
		$Panel/Detalle/Descripcion/texto.text = "Concepto"
		$Panel/Detalle/Descripcion.disabled = true
		$Panel/Detalle/Alma.hide()
		$Panel/Detalle/Religion.hide()
		$Panel/Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(id,"descripcion")
		if id == "Devotio" or id == "Reves":
			$Panel/Detalle/Imagen/TextureRect.texture = $Panel/General/ScrollContainerMaldiciones/Maldiciones.get_node(glosarioid + "/TextureRect").texture
		else:
			$Panel/Detalle/Imagen/TextureRect.texture = $Panel/General/ScrollContainerPoderes/Poderes.get_node(glosarioid + "/TextureRect").texture
	else:
		$Panel/Detalle/Descripcion/texto.text = "Historia"
		$Panel/Detalle/Alma.show()
		$Panel/Detalle/Religion.show()
		$Panel/Detalle/Descripcion.emit_signal("pressed")
	$Panel/Glosario.text = glosariotexto.get_value(id,"nombre")
	$Panel/Detalle.show()

func _on_descripcion_pressed() -> void:
	$Panel/Detalle/Descripcion.disabled = true
	$Panel/Detalle/Descripcion.set_block_signals(1)
	$Panel/Detalle/Religion.disabled = false
	$Panel/Detalle/Religion.set_block_signals(0)
	$Panel/Detalle/Alma.disabled = false
	$Panel/Detalle/Alma.set_block_signals(0)
	if glosarioid == "Caelius":
		match GameManager.player_data.tipo_caelius:
			GameManager.TipoCaelius.EGO:
				$Panel/Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"descripcionego")
			GameManager.TipoCaelius.IRA:
				$Panel/Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"descripcionira")
			GameManager.TipoCaelius.PENA:
				$Panel/Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"descripcionpena")
	else:
		$Panel/Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"descripcion")
	$Panel/Detalle/Imagen/TextureRect.texture = $Panel/General/ScrollContainerPersonajes/Personajes.get_node(glosarioid + "/TextureRect").texture


func _on_religion_pressed() -> void:
	$Panel/Detalle/Religion.disabled = true
	$Panel/Detalle/Religion.set_block_signals(1)
	$Panel/Detalle/Descripcion.disabled = false
	$Panel/Detalle/Descripcion.set_block_signals(0)
	$Panel/Detalle/Alma.disabled = false
	$Panel/Detalle/Alma.set_block_signals(0)
	$Panel/Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"religion")
	$Panel/Detalle/Imagen/TextureRect.texture = $Panel/General/ScrollContainerPersonajes/Personajes.get_node(glosarioid + "/TextureRect").texture


func _on_alma_pressed() -> void:
	$Panel/Detalle/Alma.disabled = true
	$Panel/Detalle/Alma.set_block_signals(1)
	$Panel/Detalle/Descripcion.disabled = false
	$Panel/Detalle/Descripcion.set_block_signals(0)
	$Panel/Detalle/Religion.disabled = false
	$Panel/Detalle/Religion.set_block_signals(0)
	if glosarioid == "Caelius":
		match GameManager.player_data.tipo_caelius:
			GameManager.TipoCaelius.EGO:
				$Panel/Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"almaego")
			GameManager.TipoCaelius.IRA:
				$Panel/Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"almaira")
			GameManager.TipoCaelius.PENA:
				$Panel/Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"almapena")
		$Panel/Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/fause.png")
	else:
		$Panel/Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"alma")
	match glosarioid:
		"Monaquillo":
			$Panel/Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/almamonaquillos.png")
		"Espina":
			$Panel/Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Kamathra.png")
		"Serpico":
			$Panel/Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/vahruksha.png")
		"Eirene":
			$Panel/Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Artemisia.png")
		"Corvus":
			$Panel/Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Nzolukaya.png")
		"Galaad":
			$Panel/Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Eliadran.png")
		"Kapparah":
			$Panel/Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Tzafiel.png")
