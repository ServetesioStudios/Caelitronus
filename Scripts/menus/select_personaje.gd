extends Control

@onready var pj_pena = $VBoxContainer/Personajes/PJ_pena
@onready var pj_ira = $VBoxContainer/Personajes/PJ_ira
@onready var pj_ego = $VBoxContainer/Personajes/PJ_ego

@onready var panel_info = $VBoxContainer/PanelInferior/PanelInfo
@onready var titulo = $VBoxContainer/PanelInferior/PanelInfo/Titulo
@onready var stats = $VBoxContainer/PanelInferior/PanelInfo/Stats

@onready var btn_seleccionar = $VBoxContainer/PanelInferior/BtnSeleccionar

@onready var hover_sound = $HoverSound

var personaje_actual: GameManager.TipoCaelius
var progreso = ConfigFile.new()
var statsiniciales: Array = []


func _ready() -> void:
	panel_info.visible = false
	btn_seleccionar.set_block_signals(true)
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

	pj_pena.remove_theme_stylebox_override("normal")
	pj_ira.remove_theme_stylebox_override("normal")
	pj_ego.remove_theme_stylebox_override("normal")

	btn_seleccionar.set_block_signals(false)
	btn_seleccionar.disabled = false

	match tipo:

		GameManager.TipoCaelius.PENA:
			pj_pena.add_theme_stylebox_override(
				"normal",
				pj_pena.get_theme_stylebox("hover")
			)

			titulo.text = "Caelius de Pena"
			stats.text = "Combina golpes moderados con la capacidad de sanar sus propias heridas en combate."
			statsiniciales = [85, 6, 5, 6, 9, 14, 7]

		GameManager.TipoCaelius.IRA:
			pj_ira.add_theme_stylebox_override(
				"normal",
				pj_ira.get_theme_stylebox("hover")
			)

			titulo.text = "Caelius de Ira"
			stats.text = "Favorece el daño y los golpes contundentes."
			statsiniciales = [95, 7, 4, 5, 10, 8, 8]

		GameManager.TipoCaelius.EGO:
			pj_ego.add_theme_stylebox_override(
				"normal",
				pj_ego.get_theme_stylebox("hover")
			)

			titulo.text = "Caelius de Ego"
			stats.text = "Bloqueo y resiliencia para desgastar al enemigo con paciencia."
			statsiniciales = [90, 5, 6, 4, 9, 12, 6]


func _on_btn_seleccionar_pressed() -> void:
	GameManager.iniciar_nueva_partida(personaje_actual)
	SceneManager.change_scene(SceneManager.SceneID.SELECT_NIVEL)
