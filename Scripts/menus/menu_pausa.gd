extends Control

@onready var btn_continuar: Button = $Panel/VBoxContainer/BtnContinuar
@onready var btn_ajustes: Button = $Panel/VBoxContainer/BtnAjustes
@onready var btn_menu_principal: Button = $Panel/VBoxContainer/BtnMenuPrincipal

var ajustes_abiertos: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

	btn_continuar.pressed.connect(_continuar_partida)
	btn_ajustes.pressed.connect(_abrir_ajustes)
	btn_menu_principal.pressed.connect(_volver_menu_principal)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		if ajustes_abiertos:
			return

		if visible:
			_continuar_partida()
		else:
			_pausar_partida()

		get_viewport().set_input_as_handled()


func _pausar_partida() -> void:
	show()
	get_tree().paused = true


func _continuar_partida() -> void:
	get_tree().paused = false
	hide()


func _abrir_ajustes() -> void:
	ajustes_abiertos = true

	var ajustes := SceneManager.add_overlay(
		SceneManager.SceneID.AJUSTES,
		self
	)

	if ajustes == null:
		ajustes_abiertos = false
		return

	ajustes.process_mode = Node.PROCESS_MODE_ALWAYS
	ajustes.tree_exited.connect(
		func(): ajustes_abiertos = false
	)


func _volver_menu_principal() -> void:
	GameManager.guardar_partida()

	if not GameManager.guardar_expedicion():
		push_error("No se pudo guardar la expedición.")
		return

	get_tree().paused = false

	SceneManager.change_scene(
		SceneManager.SceneID.MENU_PRINCIPAL
	)
