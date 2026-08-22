extends Control

@onready var hover_sound = $HoverSound
#var progreso = ConfigFile.new()

const JEFES_INICIALES := {
	GameManager.Jefe.ESPINA: {"nodo": "Espina", "icono": "res://assets/Icons/EspinaDerrotado.png"},
	GameManager.Jefe.SERPICO: {"nodo": "Serpico", "icono": "res://assets/Icons/SerpicoDerrotado.png"},
	GameManager.Jefe.EIRENE: {"nodo": "Eirene", "icono": "res://assets/Icons/terederrotada.png"},
}

func _ready():
	MusicManager.play_menu()
	
	var jefes := 0
	for jefe_id in JEFES_INICIALES.keys():
		if GameManager.es_jefe_derrotado(jefe_id):
			var info = JEFES_INICIALES[jefe_id]
			var boton = $Niveles/Botones.get_node(info["nodo"])
			boton.get_node("icono").texture = load(info["icono"])
			boton.add_theme_stylebox_override("normal", boton.get_theme_stylebox("pressed"))
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
		
		if GameManager.es_jefe_derrotado(GameManager.Jefe.CORVUS):
			$Niveles/Botones/Corvus/icono.texture = load("res://assets/Icons/CorvusDerrotado.png")
			$Niveles/Botones/Corvus.add_theme_stylebox_override("normal",$Niveles/Botones/Corvus.get_theme_stylebox("pressed"))
			$"Niveles/Lineas/Rojas/corvus".show()
		else:
			$Niveles/Botones/Galaad.disabled = true
			$Niveles/Botones/Galaad.set_block_signals(1)
		
		if GameManager.es_jefe_derrotado(GameManager.Jefe.GALAAD):
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
	SceneManager.change_scene(SceneManager.SceneID.MENU_PRINCIPAL)


func _on_espina_pressed() -> void:
	SceneManager.change_scene(SceneManager.SceneID.BATALLA)
