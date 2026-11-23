extends Enemy

@export var incremento_por_ataque: int = 5
@export var porcentaje_curacion: float = 1.0  # 1.0 = cura el valor del umbral completo

var contador: int = 0

func decidir_intencion() -> void:
	print("=== DEBUG MONAQUILLO LÁZARO ===")
	print("Daño actual: ", daño)
	print("Daño del recurso Stats: ", stats.daño if stats != null else "SIN STATS")

	var nueva_intencion := IntentData.new()

	if contador >= fe:
		nueva_intencion.tipo = IntentData.Tipo.HABILIDAD
		nueva_intencion.valor = int(fe * porcentaje_curacion)
		nueva_intencion.animacion = "curacion"
	else:
		var accion = randi_range(1, 100)

		if accion <= 70:
			nueva_intencion.tipo = IntentData.Tipo.ATACAR
			nueva_intencion.valor = daño
		else:
			nueva_intencion.tipo = IntentData.Tipo.DEFENDER
			nueva_intencion.valor = 5

	intencion_actual = nueva_intencion
	#contador += 1

	print("Daño del enemigo: ", daño)
	print("Valor de la intención generada: ", intencion_actual.valor)

func al_atacar() -> void:
	contador = min(contador + incremento_por_ataque, fe)

func activar_habilidad() -> void:
	super()
	habilidad_nombre = "Rezo y se cura"
	var curacion = int(fe * porcentaje_curacion)
	hp = min(hp + curacion, max_hp)
	actualizar_barra_vida()
	contador = 0
