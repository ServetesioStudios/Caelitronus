extends RefCounted
class_name EstadoExpedicion

var enemigos_por_zona: Dictionary = {}


func guardar_enemigos(zona_id: String, enemigos: Array) -> void:
	enemigos_por_zona[zona_id] = enemigos.duplicate(true)


func obtener_enemigos(zona_id: String) -> Array:
	return enemigos_por_zona.get(zona_id, []).duplicate(true)


func zona_generada(zona_id: String) -> bool:
	return enemigos_por_zona.has(zona_id)


func marcar_enemigo_derrotado(zona_id: String, enemigo_id: String) -> bool:
	if not zona_generada(zona_id):
		push_warning("EstadoExpedicion: la zona no fue generada: %s" % zona_id)
		return false

	var enemigos: Array = enemigos_por_zona[zona_id]

	for enemigo in enemigos:
		if enemigo["id"] == enemigo_id:
			enemigo["derrotado"] = true
			print("Enemigo derrotado: %s" % enemigo_id)
			return true

	push_warning("EstadoExpedicion: enemigo no encontrado: %s" % enemigo_id)
	return false
