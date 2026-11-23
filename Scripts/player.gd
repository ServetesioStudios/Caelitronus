class_name Player
extends CombatEntity

var tipo_caelius: GameManager.TipoCaelius


func _ready() -> void:
	randomize()
	nombre = "Caelius"
	tipo_caelius = GameManager.player_data.tipo_caelius
	cargar_stats()
	actualizar_barra_vida()


func _process(delta: float) -> void:
	super._process(delta)

	if Input.is_action_just_pressed("ui_accept"):
		activar_habilidad()


func cargar_stats() -> void:
	var stats: Stats = GameManager.get_stats_for(tipo_caelius)

	if stats == null:
		push_error("Player: no se pudieron cargar los stats")
		return

	print(stats.max_hp)
	aplicar_stats(stats)
	print(stats.max_hp)

	if GameManager.player_data.hp_actual >= 0:
		hp = GameManager.player_data.hp_actual


func activar_habilidad() -> void:
	if cooldown_habilidad > 0:
		return

	if habilidad_activa:
		return

	super.activar_habilidad()


func morir() -> void:
	pass
