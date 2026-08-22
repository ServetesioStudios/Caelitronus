extends Control

@onready var slider_musica = $Panel/opciones/SliderMusica
@onready var slider_efectos = $Panel/opciones/SliderEfectos
@onready var slider_voces = $Panel/opciones/SliderVoces

#@onready var preview_music = $PreviewMusic
@onready var preview_sfx = $PreviewEfectos
@onready var preview_voces = $PreviewVoces

func _ready():
	slider_musica.value = AudioSettings.music
	slider_efectos.value = AudioSettings.sfx
	slider_voces.value = AudioSettings.voces

	slider_musica.value_changed.connect(func(v): _cambiar_volumen("music", v))
	slider_efectos.value_changed.connect(func(v): _cambiar_volumen("sfx", v))
	slider_voces.value_changed.connect(func(v): _cambiar_volumen("voces", v))

	slider_efectos.drag_started.connect(func(): preview_sfx.play())
	slider_efectos.drag_ended.connect(func(_c=false): preview_sfx.stop())

	slider_voces.drag_started.connect(func(): preview_voces.play())
	slider_voces.drag_ended.connect(func(_c=false): preview_voces.stop())
	
	slider_musica.drag_ended.connect(func(_c=false): AudioSettings.guardar())
	slider_efectos.drag_ended.connect(func(_c=false): AudioSettings.guardar())
	slider_voces.drag_ended.connect(func(_c=false): AudioSettings.guardar())

func _cambiar_volumen(canal: String, value: float):
	match canal:
		"music": AudioSettings.music = value
		"sfx": AudioSettings.sfx = value
		"voces": AudioSettings.voces = value
	AudioSettings.aplicar()

func _on_btn_volver_pressed():
	AudioSettings.guardar()
	queue_free()
