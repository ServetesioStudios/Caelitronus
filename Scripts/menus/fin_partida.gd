
extends Control

@onready var label_mensaje: Label = $Mensaje
@onready var btn_accion: Button = $BtnAccion


func _ready() -> void:
	label_mensaje.text = "GAME OVER"
	btn_accion.text = "Volver al menú"
	btn_accion.pressed.connect(_volver_al_menu_principal)


func _volver_al_menu_principal() -> void:
	GameManager.limpiar_encuentro()
	GameManager.estado_expedicion = EstadoExpedicion.new()

	SceneManager.change_scene(SceneManager.SceneID.MENU_PRINCIPAL)
