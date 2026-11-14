class_name CardTooltip
extends PanelContainer

@onready var descripcion_label: RichTextLabel = $MarginContainer/Descripcion


func mostrar_carta(data: CardData) -> void:
	if data == null:
		return

	descripcion_label.text = data.descripcion
	descripcion_label.reset_size()
	reset_size()
	show()


func ocultar() -> void:
	hide()
