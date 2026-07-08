class_name CardUI
extends Control

var carta: CardData

@onready var nombre_label := $Panel/VBoxContainer/Nombre
@onready var descripcion_label := $Panel/VBoxContainer/Descripcion
@onready var costo_label := $Panel/VBoxContainer/Costo
@onready var arte_rect := $Panel/TextureRect

func setear_carta(data: CardData) -> void:
	carta = data
	nombre_label.text = data.nombre
	descripcion_label.text = data.descripcion
	costo_label.text = str(data.costo)
	if data.arte != null:
		arte_rect.texture = data.arte

func _get_drag_data(at_position: Vector2):
	var preview := duplicate()
	preview.set_anchors_preset(Control.PRESET_TOP_LEFT)
	preview.size = size
	preview.position = Vector2.ZERO
	preview.modulate.a = 0.7
	set_drag_preview(preview)
	modulate.a = 0.4
	return carta

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		modulate.a = 1.0 
