extends Control

enum TipoFinal {
	DERROTA,
	CONTINUARA,
	VICTORIA
}

@onready var label_mensaje: Label = $Mensaje
@onready var btn_accion: Button = $BtnAccion

var tipo_final: TipoFinal = TipoFinal.DERROTA


func _ready() -> void:
	btn_accion.pressed.connect(_on_btn_accion_pressed)
	actualizar_mensaje()


func configurar(tipo: TipoFinal) -> void:
	tipo_final = tipo

	if is_node_ready():
		actualizar_mensaje()


func actualizar_mensaje() -> void:
	match tipo_final:
		TipoFinal.DERROTA:
			label_mensaje.text = "GAME OVER"
			btn_accion.text = "Volver al menú"

		TipoFinal.CONTINUARA:
			label_mensaje.text = "Continuará..."
			btn_accion.text = "Volver al menú"

		TipoFinal.VICTORIA:
			label_mensaje.text = "¡VICTORIA!"
			btn_accion.text = "Continuar"


func _on_btn_accion_pressed() -> void:
	match tipo_final:
		TipoFinal.DERROTA, TipoFinal.CONTINUARA:
			GameManager.borrar_partida()
			_volver_al_menu_principal()

		TipoFinal.VICTORIA:
			_continuar_exploracion()


func _volver_al_menu_principal() -> void:
	GameManager.limpiar_encuentro()
	SceneManager.change_scene(SceneManager.SceneID.MENU_PRINCIPAL)


func _continuar_exploracion() -> void:
	SceneManager.change_scene(SceneManager.SceneID.ZONA_EIRENE)
