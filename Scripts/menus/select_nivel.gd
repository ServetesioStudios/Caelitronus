extends Control

@onready var hover_sound := $HoverSound
#var progreso = ConfigFile.new()

const COLOR_HABILITADO := Color.WHITE
const COLOR_BLOQUEADO := Color("#9a9a9a")

const JEFES_INICIALES := {
	GameManager.Jefe.ESPINA: {"nodo": "Espina", "icono": "res://assets/Icons/EspinaDerrotado.png"},
	GameManager.Jefe.SERPICO: {"nodo": "Serpico", "icono": "res://assets/Icons/SerpicoDerrotado.png"},
	GameManager.Jefe.EIRENE: {"nodo": "Eirene", "icono": "res://assets/Icons/terederrotada.png"},
}

func _ready() -> void:
	MusicManager.play_menu()

	conectar_sonidos_hover()
	configurar_niveles_iniciales()

	var jefes_derrotados := actualizar_jefes_iniciales()

	actualizar_lineas_progreso(jefes_derrotados)
	actualizar_jefes_finales(jefes_derrotados)


# --------------------------------------------------
# SONIDOS
# --------------------------------------------------

func conectar_sonidos_hover() -> void:
	for boton in $Niveles/Botones.get_children():
		if boton is Button:
			boton.mouse_entered.connect(
				_on_button_mouse_entered.bind(boton)
			)
	var boton_menu: Button = $Menuprincipal
	boton_menu.mouse_entered.connect(
		_on_button_mouse_entered.bind(boton_menu)
	)


func _on_button_mouse_entered(boton: Button) -> void:
	if boton.disabled:
		return

	if hover_sound.playing:
		hover_sound.stop()

	hover_sound.play()


# --------------------------------------------------
# ESTADOS DE LOS BOTONES
# --------------------------------------------------

func configurar_boton_nivel(boton: Button, habilitado: bool) -> void:
	boton.disabled = not habilitado

	if habilitado:
		boton.modulate = COLOR_HABILITADO
	else:
		boton.modulate = COLOR_BLOQUEADO


func configurar_niveles_iniciales() -> void:
	configurar_boton_nivel($Niveles/Botones/Espina, true)
	configurar_boton_nivel($Niveles/Botones/Eirene, true)

	# Serpico (pendiente de implementación)
	configurar_boton_nivel($Niveles/Botones/Serpico, false)


# --------------------------------------------------
# JEFES INICIALES
# --------------------------------------------------

func actualizar_jefes_iniciales() -> int:
	var cantidad_derrotados := 0

	for jefe_id in JEFES_INICIALES.keys():
		if GameManager.es_jefe_derrotado(jefe_id):
			var info = JEFES_INICIALES[jefe_id]
			var boton: Button = $Niveles/Botones.get_node(info["nodo"])

			marcar_jefe_derrotado(boton, info["icono"])
			cantidad_derrotados += 1

	return cantidad_derrotados


func marcar_jefe_derrotado(boton: Button, ruta_icono: String) -> void:
	boton.get_node("icono").texture = load(ruta_icono)

	boton.add_theme_stylebox_override(
		"normal",
		boton.get_theme_stylebox("pressed")
	)


# --------------------------------------------------
# LINEAS DE PROGRESO
# --------------------------------------------------

func actualizar_lineas_progreso(jefes_derrotados: int) -> void:
	$"Niveles/Lineas/Rojas/1".visible = jefes_derrotados >= 1
	$"Niveles/Lineas/Rojas/2".visible = jefes_derrotados >= 2
	$"Niveles/Lineas/Rojas/3".visible = jefes_derrotados >= 3


# --------------------------------------------------
# JEFES FINALES
# --------------------------------------------------

func actualizar_jefes_finales(jefes_derrotados: int) -> void:
	actualizar_corvus(jefes_derrotados)
	actualizar_galaad()
	actualizar_kapparah()


func actualizar_corvus(jefes_derrotados: int) -> void:
	var boton: Button = $Niveles/Botones/Corvus
	var habilitado := jefes_derrotados == 3

	configurar_boton_nivel(boton, habilitado)

	if GameManager.es_jefe_derrotado(GameManager.Jefe.CORVUS):
		marcar_jefe_derrotado(
			boton,
			"res://assets/Icons/CorvusDerrotado.png"
		)

		$"Niveles/Lineas/Rojas/corvus".show()
	else:
		$"Niveles/Lineas/Rojas/corvus".hide()


func actualizar_galaad() -> void:
	var boton: Button = $Niveles/Botones/Galaad
	var corvus_derrotado := GameManager.es_jefe_derrotado(
		GameManager.Jefe.CORVUS
	)

	configurar_boton_nivel(boton, corvus_derrotado)

	if GameManager.es_jefe_derrotado(GameManager.Jefe.GALAAD):
		marcar_jefe_derrotado(
			boton,
			"res://assets/Icons/GalaadDerrotado.png"
		)

		$"Niveles/Lineas/Rojas/galaad".show()
	else:
		$"Niveles/Lineas/Rojas/galaad".hide()


func actualizar_kapparah() -> void:
	var boton: Button = $Niveles/Botones/Kapparah
	var galaad_derrotado := GameManager.es_jefe_derrotado(
		GameManager.Jefe.GALAAD
	)

	configurar_boton_nivel(boton, galaad_derrotado)


# --------------------------------------------------
# NAVEGACION
# --------------------------------------------------

func _on_menuprincipal_pressed() -> void:
	SceneManager.change_scene(SceneManager.SceneID.MENU_PRINCIPAL)
	
func _on_espina_pressed() -> void:
	GameManager.seleccionar_jefe(GameManager.Jefe.ESPINA)
	SceneManager.change_scene(SceneManager.SceneID.BATALLA)

func _on_eirene_pressed() -> void:
	GameManager.seleccionar_jefe(GameManager.Jefe.EIRENE)
	SceneManager.change_scene(SceneManager.SceneID.BATALLA)
