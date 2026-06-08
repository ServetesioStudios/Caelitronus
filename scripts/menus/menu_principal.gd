extends Control

@onready var btn_continuar = $menubotones/btncontinuar
@onready var botones = $menubotones.get_children()
@onready var hover_sound = $HoverSound

var btn_pos_orig = [];
const COLOR_NORMAL := Color("#251b07")
const COLOR_HOVER := Color("#f8f5cb")
const MUSICA_MENU = preload("res://Assets/Music/Ruins.wav")

func _ready():
	AudioSettings.aplicar()
	MusicManager.play_music(MUSICA_MENU)

	if hay_partida_guardada():
		btn_continuar.visible = true
	else:
		btn_continuar.visible = false

	await get_tree().process_frame
	for btn in botones:
		btn_pos_orig.append(btn.position)
		if btn is Button:
			btn.mouse_entered.connect(func(): _on_hover(btn))
			btn.mouse_exited.connect(func(): _on_hover_exit(btn))
		
func aplicar_audio():
	if not FileAccess.file_exists("user://settings.dat"):
		return

	var file = FileAccess.open("user://settings.dat", FileAccess.READ)
	var data: Dictionary = file.get_var()
	file.close()

	set_bus_volume("Music", data.get("music", 100))
	set_bus_volume("SFX", data.get("sfx", 100))
	set_bus_volume("Voces", data.get("voces", 100))

func set_bus_volume(bus_name: String, value: float):
	var bus := AudioServer.get_bus_index(bus_name)
	if bus == -1:
		push_warning("Bus no encontrado: " + bus_name)
		return

	AudioServer.set_bus_volume_db(
		bus,
		linear_to_db(value / 100.0)
	)

func _on_hover(btn: Button):
	var tween = create_tween()
	tween.parallel().tween_property(btn, "scale", Vector2(0.9, 0.9), 0.15)
	tween.parallel().tween_property(btn, "position:x", btn.position.x + 20, 0.15)
	
	btn.add_theme_color_override("font_color", COLOR_HOVER)
	
	if hover_sound:
		hover_sound.play()

func _on_hover_exit(btn: Button):
	var tween = create_tween()
	var indice = botones.find(btn)
	var vectorOriginal = btn_pos_orig[indice]
	
	tween.parallel().tween_property(btn, "scale", Vector2.ONE, 0.15)
	tween.parallel().tween_property(btn, "position:x", vectorOriginal.x, 0.15)
	
	btn.add_theme_color_override("font_color", COLOR_NORMAL)

func hay_partida_guardada() -> bool:
	return FileAccess.file_exists("user://save.dat")

func _on_btncontinuar_pressed():
	get_tree().change_scene_to_file("res://scenes/juego.tscn")
	MusicManager.play_music(MUSICA_MENU)

func _on_bntcomenzar_pressed():
	if FileAccess.file_exists("user://save.dat"):
		DirAccess.remove_absolute("user://save.dat")
	MusicManager.stop_music()
	get_tree().change_scene_to_file("res://scenes/cinematicas/cinematica_inicio.tscn")

func _on_bntajustes_pressed():
	#get_tree().change_scene_to_file("res://scenes/ajustes.tscn")
	var ajustes = preload("res://scenes/menus/ajustes.tscn").instantiate()
	add_child(ajustes)

func _on_btnglosario_pressed():
	#get_tree().change_scene_to_file("res://scenes/glosario.tscn")
	var glosario = preload("res://scenes/menus/glosario.tscn").instantiate()
	add_child(glosario)

func _on_btncreditos_pressed():
	#get_tree().change_scene_to_file("res://scenes/creditos.tscn")
	var creditos = preload("res://scenes/menus/creditos.tscn").instantiate()
	add_child(creditos)

func _on_btnsalir_pressed():
	get_tree().quit()
