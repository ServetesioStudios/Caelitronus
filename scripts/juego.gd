extends Control

func _ready() -> void:
	var seleccionPersonaje = preload("res://scenes/menus/seleccionar_personaje.tscn").instantiate()
	add_child(seleccionPersonaje)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
