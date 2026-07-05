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
					$General/ScrollContainerPersonajes/Personajes/Caelius/TextureRect.texture = load("res://assets/ChArt/caelius de ego.png")
				GameManager.TipoCaelius.IRA:
					$General/ScrollContainerPersonajes/Personajes/Caelius/TextureRect.texture = load("res://assets/ChArt/caelius de ira.png")
				GameManager.TipoCaelius.PENA:
					$General/ScrollContainerPersonajes/Personajes/Caelius/TextureRect.texture = load("res://assets/ChArt/caelius de pena.png")
	else:
		ocultar("Caelius")
		$General/ScrollContainerMaldiciones/Maldiciones/Reves/TextureRect.modulate = Color()
		$General/ScrollContainerMaldiciones/Maldiciones/Reves/Label.text = "???"
		$General/ScrollContainerMaldiciones/Maldiciones/Reves/Button.disabled = true
		$General/ScrollContainerMaldiciones/Maldiciones/Reves/Button.set_block_signals(1)

	for jefe_nombre in GameManager.Jefe.keys():
		var jefe_id = GameManager.Jefe[jefe_nombre]
		if not GameManager.es_jefe_derrotado(jefe_id):
			ocultar(jefe_nombre.capitalize())	
		
func ocultar(nombre):
	$General/ScrollContainerPersonajes/Personajes.get_node(nombre + "/TextureRect").modulate = Color()
	$General/ScrollContainerPersonajes/Personajes.get_node(nombre + "/Label").text = "???"
	$General/ScrollContainerPersonajes/Personajes.get_node(nombre + "/Button").disabled = true
	$General/ScrollContainerPersonajes/Personajes.get_node(nombre + "/Button").set_block_signals(1)


func _on_atras_pressed() -> void:
	if $Detalle.visible:
		$Detalle.hide()
		$General.show()
		$Glosario.text = "Glosario"
	else:
		queue_free()


func _on_button_mouse_entered() -> void:
	if hover_sound.playing == true:
		hover_sound.stop()
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
	var err = glosariotexto.load("res://Data/text/glosario.cfg")
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
	$Detalle/Descripcion.set_block_signals(1)
	$Detalle/Religion.disabled = false
	$Detalle/Religion.set_block_signals(0)
	$Detalle/Alma.disabled = false
	$Detalle/Alma.set_block_signals(0)
	if glosarioid == "Caelius":
		match GameManager.player_data.tipo_caelius:
			GameManager.TipoCaelius.EGO:
				$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"descripcionego")
			GameManager.TipoCaelius.IRA:
				$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"descripcionira")
			GameManager.TipoCaelius.PENA:
				$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"descripcionpena")
	else:
		$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"descripcion")
	$Detalle/Imagen/TextureRect.texture = $General/ScrollContainerPersonajes/Personajes.get_node(glosarioid + "/TextureRect").texture


func _on_religion_pressed() -> void:
	$Detalle/Religion.disabled = true
	$Detalle/Religion.set_block_signals(1)
	$Detalle/Descripcion.disabled = false
	$Detalle/Descripcion.set_block_signals(0)
	$Detalle/Alma.disabled = false
	$Detalle/Alma.set_block_signals(0)
	$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"religion")
	$Detalle/Imagen/TextureRect.texture = $General/ScrollContainerPersonajes/Personajes.get_node(glosarioid + "/TextureRect").texture


func _on_alma_pressed() -> void:
	$Detalle/Alma.disabled = true
	$Detalle/Alma.set_block_signals(1)
	$Detalle/Descripcion.disabled = false
	$Detalle/Descripcion.set_block_signals(0)
	$Detalle/Religion.disabled = false
	$Detalle/Religion.set_block_signals(0)
	if glosarioid == "Caelius":
		match GameManager.player_data.tipo_caelius:
			GameManager.TipoCaelius.EGO:
				$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"almaego")
			GameManager.TipoCaelius.IRA:
				$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"almaira")
			GameManager.TipoCaelius.PENA:
				$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"almapena")
		$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/fause.png")
	else:
		$Detalle/Texto/RichTextLabel.text = glosariotexto.get_value(glosarioid,"alma")
	match glosarioid:
		"Monaquillo":
			$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/almamonaquillos.png")
		"Espina":
			$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Kamathra.png")
		"Serpico":
			$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/vahruksha.png")
		"Eirene":
			$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Artemisia.png")
		"Corvus":
			$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Nzolukaya.png")
		"Galaad":
			$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Eliadran.png")
		"Kapparah":
			$Detalle/Imagen/TextureRect.texture = load("res://assets/BttlSprit/Tzafiel.png")
