extends Control

@export var theme_data: UIThemeData
#@export var audio_library: AudioLibrary

@onready var btn_continuar = $menubotones/btncontinuar
@onready var botones = $menubotones.get_children()
@onready var hover_sound = $HoverSound

var color_normal := Color(0.19, 0.19, 0.19, 1.0)
var color_hover := Color(1.15, 1.15, 1.05, 1.0)

var btn_pos_orig = []
var tweens_hover: Dictionary = {}

func _ready():
	MusicManager.play_menu()
	AudioSettings.aplicar()
	
	#HAY PARTIDA GUARDADA?
	var tiene_partida := GameManager.hay_partida_guardada()
	btn_continuar.visible = tiene_partida
	btn_continuar.disabled = not tiene_partida

	await get_tree().process_frame
	for btn in botones:
		btn_pos_orig.append(btn.position)

		if btn is Button:
			btn.modulate = color_normal

			btn.mouse_entered.connect(func(): _on_hover(btn))
			btn.mouse_exited.connect(func(): _on_hover_exit(btn))

func _on_hover(btn: Button) -> void:
	animar_color_boton(btn, color_hover)

	if hover_sound:
		hover_sound.play()

func _on_hover_exit(btn: Button) -> void:
	animar_color_boton(btn, color_normal)
	
func animar_color_boton(btn: Button, color_destino: Color) -> void:
	if tweens_hover.has(btn):
		var tween_anterior: Tween = tweens_hover[btn]

		if tween_anterior.is_running():
			tween_anterior.kill()

	var tween = create_tween()
	tweens_hover[btn] = tween

	tween.tween_property(
		btn,
		"modulate",
		color_destino,
		0.20).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_btncontinuar_pressed():
	GameManager.cargar_partida()
	SceneManager.change_scene(SceneManager.SceneID.SELECT_PERSONAJE)
	MusicManager.play_menu()

func _on_bntcomenzar_pressed():
	GameManager.borrar_partida()
	MusicManager.stop_music()
	SceneManager.change_scene(SceneManager.SceneID.CINEMATICA_INICIO)

func _on_bntajustes_pressed():
	SceneManager.add_overlay(SceneManager.SceneID.AJUSTES, self)

func _on_btnglosario_pressed():
	SceneManager.add_overlay(SceneManager.SceneID.GLOSARIO, self)

func _on_btncreditos_pressed():
	SceneManager.add_overlay(SceneManager.SceneID.CREDITOS, self)

func _on_btnsalir_pressed():
	get_tree().quit()
