class_name CardUI
extends Control

var carta: CardData

@onready var nombre_label := $Panel/VBoxContainer/Nombre
@onready var costo_label := $Panel/VBoxContainer/Costo
@onready var arte_rect := $Panel/TextureRect

func setear_carta(data: CardData) -> void:
	carta = data
	nombre_label.text = data.nombre
	costo_label.text = "Costo:" + str(data.costo)
	if data.arte != null:
		arte_rect.texture = data.arte

func _get_drag_data(_position):
	var preview := TextureRect.new()
	preview.texture = arte_rect.texture
	preview.custom_minimum_size = Vector2(150, 220)

	set_drag_preview(preview)

	modulate.a = 0.4
	return carta

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		modulate.a = 1.0 
