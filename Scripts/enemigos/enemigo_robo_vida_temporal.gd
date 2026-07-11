extends Enemy

@export var bonus_daño_habilidad: float = 1.25
@export var duracion_turnos: int = 3
@export var turnos_cooldown: int = 4

var turnos_restantes_buff: int = 0
var turnos_restantes_cooldown: int = 0

func decidir_intencion() -> void:
	var nueva_intencion := IntentData.new()
	
	if turnos_restantes_cooldown <= 0:
		nueva_intencion.tipo = IntentData.Tipo.HABILIDAD
		nueva_intencion.valor = 0
	else:
		nueva_intencion.tipo = IntentData.Tipo.ATACAR
		nueva_intencion.valor = daño
		#var accion = randi() % 2
		#match accion:
			#0:
				#nueva_intencion.tipo = IntentData.Tipo.ATACAR
				#nueva_intencion.valor = daño
			#1:
				#nueva_intencion.tipo = IntentData.Tipo.DEFENDER
				#nueva_intencion.valor = 5
	intencion_actual = nueva_intencion

func activar_habilidad() -> void:
	super()
	habilidad_nombre = "Hambre" 
	robo_vida = true
	
	bonus_daño = bonus_daño_habilidad
	turnos_restantes_buff = duracion_turnos
	turnos_restantes_cooldown = turnos_cooldown

func procesar_estados() -> void:
	super.procesar_estados()
	
	
	if turnos_restantes_cooldown > 0:
		turnos_restantes_cooldown -= 1
	if turnos_restantes_buff > 0:
		turnos_restantes_buff -= 1
		if turnos_restantes_buff <= 0:
			robo_vida = false
			bonus_daño = 1.0
