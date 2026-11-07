extends Control

@onready var label_mensaje := $Mensaje
@onready var btn_accion := $BtnAccion

func configurar(victoria: bool, es_ultimo_combate: bool) -> void:
	if not victoria:
		label_mensaje.text = "GAME OVER"
		btn_accion.text = "Volver al menú"
		btn_accion.pressed.connect(_volver_al_menu_principal)
	elif es_ultimo_combate:
		label_mensaje.text = "¡Ganaste!"
		btn_accion.text = "Volver"
		btn_accion.pressed.connect(_volver_al_mapa)
	else:
		label_mensaje.text = "¡Victoria!"
		btn_accion.text = "Siguiente"
		btn_accion.pressed.connect(_siguiente_combate)

func _siguiente_combate() -> void:
	GameManager.avanzar_combate()
	SceneManager.change_scene(SceneManager.SceneID.BATALLA)

func _volver_al_mapa() -> void:
	GameManager.reiniciar_secuencia_combates()
	SceneManager.change_scene(SceneManager.SceneID.SELECT_NIVEL)

func _volver_al_menu_principal() -> void:
	GameManager.reiniciar_secuencia_combates()
	GameManager.limpiar_encuentro()
	GameManager.estado_expedicion = EstadoExpedicion.new()
	SceneManager.change_scene(SceneManager.SceneID.MENU_PRINCIPAL)
