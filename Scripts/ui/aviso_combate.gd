class_name AvisoCombate
extends Label

@export_group("Animación")
@export var duracion_visible: float = 1.5
@export var duracion_desvanecimiento: float = 0.4

var tween_aviso: Tween


func _ready() -> void:
	hide()


func mostrar(mensaje: String) -> void:
	if tween_aviso != null and tween_aviso.is_running():
		tween_aviso.kill()

	text = mensaje
	modulate.a = 1.0
	show()

	tween_aviso = create_tween()
	tween_aviso.tween_interval(duracion_visible)

	tween_aviso.tween_property(
		self,
		"modulate:a",
		0.0,
		duracion_desvanecimiento
	)

	tween_aviso.tween_callback(hide)


func _exit_tree() -> void:
	if tween_aviso != null and tween_aviso.is_running():
		tween_aviso.kill()
