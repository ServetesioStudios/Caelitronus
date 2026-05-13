extends Control

@onready var pj_pena = $Personajes/PJ_pena
@onready var pj_ira = $Personajes/PJ_ira
@onready var pj_ego = $Personajes/PJ_ego

@onready var panel_info = $PanelInfo
@onready var titulo = $PanelInfo/Titulo
@onready var stats = $PanelInfo/Stats

@onready var btn_seleccionar = $BtnSeleccionar

@onready var hover_sound = $HoverSound

var personaje_actual: String = ""
var progreso = ConfigFile.new()

func _ready() -> void:
	panel_info.visible = false
	btn_seleccionar.set_block_signals(1)
	btn_seleccionar.disabled = true

	pj_pena.mouse_entered.connect(_on_hover)
	pj_ira.mouse_entered.connect(_on_hover)
	pj_ego.mouse_entered.connect(_on_hover)

	#pj_pena.pressed.connect(_on_pj_pena_pressed)
	#pj_ira.pressed.connect(_on_pj_ira_pressed)
	#pj_ego.pressed.connect(_on_pj_ego_pressed)

	btn_seleccionar.pressed.connect(_on_btn_seleccionar_pressed)


func _on_hover() -> void:
	if hover_sound.playing:
		hover_sound.stop()
	hover_sound.play()

func _on_pj_pena_pressed() -> void:
	seleccionar_personaje("pena")

func _on_pj_ira_pressed() -> void:
	seleccionar_personaje("ira")

func _on_pj_ego_pressed() -> void:
	seleccionar_personaje("ego")

func seleccionar_personaje(tipo: String) -> void:
	personaje_actual = tipo
	panel_info.visible = true
	$Personajes/PJ_pena.remove_theme_stylebox_override("normal")
	$Personajes/PJ_ira.remove_theme_stylebox_override("normal")
	$Personajes/PJ_ego.remove_theme_stylebox_override("normal")
	btn_seleccionar.set_block_signals(0)
	btn_seleccionar.disabled = false

	match tipo:
		"pena":
			$Personajes/PJ_pena.add_theme_stylebox_override("normal",$Personajes/PJ_pena.get_theme_stylebox("hover"))
			titulo.text = "Caelius de Pena"
			stats.text = "Incrementa el valor de fe y sus valores de esquive y velocidad en un 20% por 5 segundos."

		"ira":
			$Personajes/PJ_ira.add_theme_stylebox_override("normal",$Personajes/PJ_ira.get_theme_stylebox("hover"))
			titulo.text = "Caelius de Ira"
			stats.text = "Incrementa el valor de ataque y daño en un 30% por 5 segundos."

		"ego":
			$Personajes/PJ_ego.add_theme_stylebox_override("normal",$Personajes/PJ_ego.get_theme_stylebox("hover"))
			titulo.text = "Caelius de Ego"
			stats.text = "Incrementa su valor de defensa un 40% por 5 segundos y se cura un 10%."

func _on_btn_seleccionar_pressed() -> void:

	var save_data := {
		"personaje": personaje_actual
	}

	var file := FileAccess.open("user://save.dat", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
	
	var err = progreso.load("res://cfg/progreso.cfg")
	if err == OK:
		progreso.set_value("Caelius","tipo",personaje_actual)
		progreso.save("res://cfg/progreso.cfg")

	get_tree().change_scene_to_file("res://scenes/select_nivel.tscn")
