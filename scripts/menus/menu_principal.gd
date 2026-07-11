extends Control

@export var theme_data: UIThemeData
#@export var audio_library: AudioLibrary

@onready var btn_continuar = $menubotones/btncontinuar
@onready var botones = $menubotones.get_children()
@onready var hover_sound = $HoverSound

var btn_pos_orig = [];

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
			btn.mouse_entered.connect(func(): _on_hover(btn))
			btn.mouse_exited.connect(func(): _on_hover_exit(btn))

func _on_hover(btn: Button):
	var tween = create_tween()
	tween.parallel().tween_property(btn, "scale", Vector2(0.9, 0.9), 0.15)
	tween.parallel().tween_property(btn, "position:x", btn.position.x + 20, 0.15)
	
	btn.modulate = theme_data.color_hover
	
	if hover_sound:
		hover_sound.play()

func _on_hover_exit(btn: Button):
	var tween = create_tween()
	var indice = botones.find(btn)
	var vectorOriginal = btn_pos_orig[indice]
	
	tween.parallel().tween_property(btn, "scale", Vector2.ONE, 0.15)
	tween.parallel().tween_property(btn, "position:x", vectorOriginal.x, 0.15)
	
	btn.modulate = theme_data.color_normal

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
