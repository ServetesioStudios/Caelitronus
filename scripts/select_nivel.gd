extends Control


@onready var hover_sound = $HoverSound
var progreso = ConfigFile.new()


func _ready():
	var err = progreso.load("res://cfg/progreso.cfg")
	if err == OK:
		
		var jefes = 0
		if progreso.get_value("Jefes","espina") == 1:
			$Niveles/Botones/Espina/icono.texture = load("res://assets/Icons/EspinaDerrotado.png")
			$Niveles/Botones/Espina.add_theme_stylebox_override("normal",$Niveles/Botones/Espina.get_theme_stylebox("pressed"))
			jefes += 1
		if progreso.get_value("Jefes","serpico") == 1:
			$Niveles/Botones/Serpico/icono.texture = load("res://assets/Icons/SerpicoDerrotado.png")
			$Niveles/Botones/Serpico.add_theme_stylebox_override("normal",$Niveles/Botones/Serpico.get_theme_stylebox("pressed"))
			jefes += 1
		if progreso.get_value("Jefes","eirene") == 1:
			$Niveles/Botones/Eirene/icono.texture = load("res://assets/Icons/terederrotada.png")
			$Niveles/Botones/Eirene.add_theme_stylebox_override("normal",$Niveles/Botones/Eirene.get_theme_stylebox("pressed"))
			jefes += 1		
		if jefes > 0:
			$"Niveles/Lineas/Rojas/1".show()
			if jefes > 1:
				$"Niveles/Lineas/Rojas/2".show()
				if jefes > 2:
					$"Niveles/Lineas/Rojas/3".show()
		if jefes < 3:
			$Niveles/Botones/Corvus.disabled = true
			$Niveles/Botones/Corvus.set_block_signals(1)
		if progreso.get_value("Jefes","corvus") == 1:
			$Niveles/Botones/Corvus/icono.texture = load("res://assets/Icons/CorvusDerrotado.png")
			$Niveles/Botones/Corvus.add_theme_stylebox_override("normal",$Niveles/Botones/Corvus.get_theme_stylebox("pressed"))
			$"Niveles/Lineas/Rojas/corvus".show()
		else:
			$Niveles/Botones/Galaad.disabled = true
			$Niveles/Botones/Galaad.set_block_signals(1)
		if progreso.get_value("Jefes","galaad") == 1:
			$Niveles/Botones/Galaad/icono.texture = load("res://assets/Icons/GalaadDerrotado.png")
			$Niveles/Botones/Galaad.add_theme_stylebox_override("normal",$Niveles/Botones/Galaad.get_theme_stylebox("pressed"))
			$"Niveles/Lineas/Rojas/galaad".show()
		else:
			$Niveles/Botones/Kapparah.disabled = true
			$Niveles/Botones/Kapparah.set_block_signals(1)
				

func _on_button_mouse_entered() -> void:
	if hover_sound.playing == true:
		hover_sound.stop()
	hover_sound.play()
	

func _on_menuprincipal_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
