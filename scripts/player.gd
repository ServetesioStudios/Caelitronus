class_name Player
extends CombatEntity

signal energia_actualizada(actual: int, maxima: int)

var tipo_caelius : GameManager.TipoCaelius
var energia_maxima: int = 3
var energia_actual: int = 3

func _ready():
	randomize()
	nombre = "Caelius"
	tipo_caelius = GameManager.player_data.tipo_caelius
	cargar_stats()
	_definir_energia_maxima()
	actualizar_barra_vida()

func _process(delta):
	super._process(delta)
	
	if Input.is_action_just_pressed("ui_accept"):
		activar_habilidad()
		
func cargar_stats():
	var stats: Stats = GameManager.get_stats_for(tipo_caelius)
	if stats == null:
		push_error("Player: no se pudieron cargar los stats")
		return
	aplicar_stats(stats)

func _definir_energia_maxima() -> void:
	match tipo_caelius:
		GameManager.TipoCaelius.IRA:
			energia_maxima = 3
		GameManager.TipoCaelius.PENA:
			energia_maxima = 3
		GameManager.TipoCaelius.EGO:
			energia_maxima = 3

func resetear_energia() -> void:
	energia_actual = energia_maxima
	energia_actualizada.emit(energia_actual, energia_maxima)
	
func puede_pagar(costo: int) -> bool:
	return energia_actual >= costo

func gastar_energia(costo: int) -> bool:
	if not puede_pagar(costo):
		return false
	energia_actual -= costo
	energia_actualizada.emit(energia_actual, energia_maxima)
	return true

func sumar_energia(cantidad: int) -> void: 
	energia_actual = min(energia_actual + cantidad, energia_maxima)
	energia_actualizada.emit(energia_actual, energia_maxima)

func activar_habilidad():
	if cooldown_habilidad > 0:
		return
	if habilidad_activa:
		return
	
	super.activar_habilidad()
	#match tipo_caelius:
		#GameManager.TipoCaelius.IRA:
			#habilidad_nombre = "Ira del Depredador"
			#habilidad_timer = 5.0
			#bonus_daño = 1.25
			#bonus_defensa = 1.2
			#bonus_velocidad = 1.15
		#GameManager.TipoCaelius.PENA:
			#habilidad_nombre = "Lamento Parasitario"
			#habilidad_timer = 5.0
			#robo_vida = true
		#GameManager.TipoCaelius.EGO:
			#habilidad_nombre = "Dominio Absoluto"
			#habilidad_timer = 4.0
			#inmune = true
			#doble_golpe = true
	#cooldown_habilidad = max(18.0 - (fe * 0.08), 10.0)
	
func morir() -> void: 
	pass
