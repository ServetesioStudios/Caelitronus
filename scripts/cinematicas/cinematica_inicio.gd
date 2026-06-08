extends Control

@onready var video := $inicio
@onready var audio := $voces

func _ready():
	video.play()
	audio.play()

func _input(event):
	if event.is_action_pressed("ui_accept") or event is InputEventMouseButton:
		_iniciar_Juego()


func _on_inicio_finished() -> void:
	_iniciar_Juego()
	

func _iniciar_Juego():
	get_tree().change_scene_to_file("res://scenes/juego.tscn")
