extends Control

@onready var slider_musica = $opciones/SliderMusica
@onready var slider_efectos = $opciones/SliderEfectos
@onready var slider_voces = $opciones/SliderVoces

@onready var preview_music = $PreviewMusic
@onready var preview_sfx = $PreviewEfectos
@onready var preview_voces = $PreviewVoces

func _ready():
	slider_musica.value = AudioSettings.music
	slider_efectos.value = AudioSettings.sfx
	slider_voces.value = AudioSettings.voces

	slider_musica.value_changed.connect(_on_music_changed)
	slider_efectos.value_changed.connect(_on_sfx_changed)
	slider_voces.value_changed.connect(_on_voces_changed)

	#slider_musica.drag_started.connect(func(): preview_music.play())
	#slider_musica.drag_ended.connect(func(_c=false): preview_music.stop())

	slider_efectos.drag_started.connect(func(): preview_sfx.play())
	slider_efectos.drag_ended.connect(func(_c=false): preview_sfx.stop())

	slider_voces.drag_started.connect(func(): preview_voces.play())
	slider_voces.drag_ended.connect(func(_c=false): preview_voces.stop())

func _on_music_changed(value):
	AudioSettings.music = value
	AudioSettings.aplicar()
	AudioSettings.guardar()

func _on_sfx_changed(value):
	AudioSettings.sfx = value
	AudioSettings.aplicar()
	AudioSettings.guardar()

func _on_voces_changed(value):
	AudioSettings.voces = value
	AudioSettings.aplicar()
	AudioSettings.guardar()

func _on_btn_volver_pressed():
	#get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
	queue_free()
