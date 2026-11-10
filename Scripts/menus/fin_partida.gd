extends Control

enum TipoFinal {
	DERROTA,
	CONTINUARA
}

@onready var label_mensaje: Label = $Mensaje
@onready var btn_accion: Button = $BtnAccion

var tipo_final: TipoFinal = TipoFinal.DERROTA


func _ready() -> void:
	btn_accion.text = "Volver al menú"
	btn_accion.pressed.connect(_volver_al_menu_principal)

	actualizar_mensaje()


func configurar(tipo: TipoFinal) -> void:
	tipo_final = tipo

	if is_node_ready():
		actualizar_mensaje()


func actualizar_mensaje() -> void:
	match tipo_final:
		TipoFinal.DERROTA:
			label_mensaje.text = "GAME OVER"

		TipoFinal.CONTINUARA:
			label_mensaje.text = "Continuará..."


func _volver_al_menu_principal() -> void:
	GameManager.limpiar_encuentro()
	GameManager.estado_expedicion = EstadoExpedicion.new()

	SceneManager.change_scene(SceneManager.SceneID.MENU_PRINCIPAL)
