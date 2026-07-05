extends Enemy

var veneno_activo = false
var fase_desesperacion = false
var posicion_original = Vector2.ZERO

func _ready():
	super._ready()
	posicion_original = position
	if has_node("AnimationPlayer") and $AnimationPlayer.has_animation("idle"):
		$AnimationPlayer.play("idle")

func _process(delta):
	super._process(delta)
	if hp <= max_hp * 0.25 and not fase_desesperacion:
		activar_fase_desesperacion()
	if fase_desesperacion:
		temblar()

func evaluar_activacion_habilidad() -> void:
	if hp <= max_hp * 0.75:
		activar_habilidad()

func activar_habilidad() -> void:
	if habilidad_activa:
		return
	super.activar_habilidad()
	habilidad_nombre = "Éxtasis Prohibido"
	habilidad_timer = 5.0
	cooldown_habilidad = 25.0
	bonus_daño = 1.35
	bonus_defensa = 1.25
	bonus_velocidad = 1.15
	veneno_activo = true

func desactivar_habilidad() -> void:
	super.desactivar_habilidad()
	veneno_activo = false

func activar_fase_desesperacion() -> void:
	fase_desesperacion = true
	color_base = Color(1.0, 0.7, 0.8, 1.0)
	modulate = color_base

func temblar() -> void:
	position = posicion_original + Vector2(randf_range(-2, 2), randf_range(-2, 2))
