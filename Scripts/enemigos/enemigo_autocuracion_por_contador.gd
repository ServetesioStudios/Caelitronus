extends Enemy

@export var incremento_por_ataque: int = 4
@export var porcentaje_curacion: float = 1.0  # 1.0 = cura el valor del umbral completo

var contador: int = 0

func decidir_intencion() -> void:
	var nueva_intencion := IntentData.new()
	if contador >= fe:
		nueva_intencion.tipo = IntentData.Tipo.HABILIDAD
		nueva_intencion.valor = int(fe * porcentaje_curacion)
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

func al_atacar() -> void:
	contador = min(contador + incremento_por_ataque, fe)

func activar_habilidad() -> void:
	super()
	habilidad_nombre = "Rezo y se cura"
	var curacion = int(fe * porcentaje_curacion)
	hp = min(hp + curacion, max_hp)
	actualizar_barra_vida()
	contador = 0
