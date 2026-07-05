extends CombatEntity

var tipo_caelius : GameManager.TipoCaelius

func _ready():
	randomize()
	nombre = "Caelius"
	tipo_caelius = GameManager.player_data.tipo_caelius
	cargar_stats()
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

func activar_habilidad():
	if cooldown_habilidad > 0:
		return
	if habilidad_activa:
		return
	
	super.activar_habilidad()
	match tipo_caelius:
		GameManager.TipoCaelius.IRA:
			habilidad_nombre = "Ira del Depredador"
			habilidad_timer = 5.0
			bonus_daño = 1.25
			bonus_defensa = 1.2
			bonus_velocidad = 1.15
		GameManager.TipoCaelius.PENA:
			habilidad_nombre = "Lamento Parasitario"
			habilidad_timer = 5.0
			robo_vida = true
		GameManager.TipoCaelius.EGO:
			habilidad_nombre = "Dominio Absoluto"
			habilidad_timer = 4.0
			inmune = true
			doble_golpe = true
	cooldown_habilidad = max(18.0 - (fe * 0.08), 10.0)
