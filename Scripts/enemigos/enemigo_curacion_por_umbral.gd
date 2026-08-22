extends Enemy

@export var umbral_hp_porcentaje: float = 0.45
@export var porcentaje_curacion: float = 0.15
@export var bonus_defensa_habilidad: float = 1.3
@export var duracion_turnos: int = 3

var turnos_restantes_buff: int = 0

func decidir_intencion() -> void:
	var nueva_intencion := IntentData.new()
	if hp < max_hp * umbral_hp_porcentaje and turnos_restantes_buff <= 0:
		nueva_intencion.tipo = IntentData.Tipo.HABILIDAD
		nueva_intencion.valor = int(max_hp * porcentaje_curacion)
		nueva_intencion.animacion = "curacion"
	else:
		var accion = randi() % 2
		match accion:
			0:
				nueva_intencion.tipo = IntentData.Tipo.ATACAR
				nueva_intencion.valor = daño
			1:
				nueva_intencion.tipo = IntentData.Tipo.DEFENDER
				nueva_intencion.valor = 5
	intencion_actual = nueva_intencion

func activar_habilidad() -> void:
	super()
	habilidad_nombre = "Último Consuelo y se cura"
	var curacion = int(max_hp * porcentaje_curacion)
	hp = min(hp + curacion, max_hp)
	bonus_defensa = bonus_defensa_habilidad
	turnos_restantes_buff = duracion_turnos
	actualizar_barra_vida()

func procesar_estados() -> void:
	super.procesar_estados()
	if turnos_restantes_buff > 0:
		turnos_restantes_buff -= 1
		if turnos_restantes_buff <= 0:
			bonus_defensa = 1.0
