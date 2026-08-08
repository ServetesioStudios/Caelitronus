extends Control

@onready var pj_pena = $Personajes/PJ_pena
@onready var pj_ira = $Personajes/PJ_ira
@onready var pj_ego = $Personajes/PJ_ego

@onready var panel_info = $PanelInfo
@onready var titulo = $PanelInfo/Titulo
@onready var stats = $PanelInfo/Stats

@onready var btn_seleccionar = $BtnSeleccionar

@onready var hover_sound = $HoverSound

var personaje_actual: GameManager.TipoCaelius
var progreso = ConfigFile.new()
var statsiniciales: Array = []


func _ready() -> void:
	panel_info.visible = false
	btn_seleccionar.set_block_signals(1)
	btn_seleccionar.disabled = true

	pj_pena.mouse_entered.connect(_on_hover)
	pj_ira.mouse_entered.connect(_on_hover)
	pj_ego.mouse_entered.connect(_on_hover)
	btn_seleccionar.mouse_entered.connect(_on_hover)

	btn_seleccionar.pressed.connect(_on_btn_seleccionar_pressed)

func _on_hover() -> void:
	if hover_sound.playing:
		hover_sound.stop()
	hover_sound.play()

func _on_pj_pena_pressed() -> void:
	seleccionar_personaje(GameManager.TipoCaelius.PENA)

func _on_pj_ira_pressed() -> void:
	seleccionar_personaje(GameManager.TipoCaelius.IRA)

func _on_pj_ego_pressed() -> void:
	seleccionar_personaje(GameManager.TipoCaelius.EGO)

func seleccionar_personaje(tipo: GameManager.TipoCaelius) -> void:
	personaje_actual = tipo
	panel_info.visible = true
	$Personajes/PJ_pena.remove_theme_stylebox_override("normal")
	$Personajes/PJ_ira.remove_theme_stylebox_override("normal")
	$Personajes/PJ_ego.remove_theme_stylebox_override("normal")
	btn_seleccionar.set_block_signals(0)
	btn_seleccionar.disabled = false

	match tipo:
		GameManager.TipoCaelius.PENA:
			$Personajes/PJ_pena.add_theme_stylebox_override("normal",$Personajes/PJ_pena.get_theme_stylebox("hover"))
			titulo.text = "Caelius de Pena"
			stats.text = "Combina golpes moderados con la capacidad de sanar sus propias heridas en combate."
			#stats.text = "Incrementa el valor de fe y sus valores de esquive y velocidad en un 20% por 5 segundos."
			statsiniciales = [85,6,5,6,9,14,7]
		GameManager.TipoCaelius.IRA:
			$Personajes/PJ_ira.add_theme_stylebox_override("normal",$Personajes/PJ_ira.get_theme_stylebox("hover"))
			titulo.text = "Caelius de Ira"
			stats.text = "Favorece el daño y los golpes contundentes."
			#stats.text = "Incrementa el valor de ataque y daño en un 30% por 5 segundos."
			statsiniciales = [95,7,4,5,10,8,8]
		GameManager.TipoCaelius.EGO:
			$Personajes/PJ_ego.add_theme_stylebox_override("normal",$Personajes/PJ_ego.get_theme_stylebox("hover"))
			titulo.text = "Caelius de Ego" 
			stats.text = "Bloqueo y resiliencia para desgastar al enemigo con paciencia."
			#stats.text = "Incrementa su valor de defensa un 40% por 5 segundos y se cura un 10%."
			statsiniciales = [90,5,6,4,9,12,6]

func _on_btn_seleccionar_pressed() -> void:
	GameManager.iniciar_nueva_partida(personaje_actual)
	SceneManager.change_scene(SceneManager.SceneID.SELECT_NIVEL)
