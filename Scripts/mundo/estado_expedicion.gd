extends RefCounted
class_name EstadoExpedicion

var enemigos_por_zona: Dictionary = {}
var jefes_derrotados_por_zona: Dictionary = {}



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
	


func todos_enemigos_derrotados(zona_id: String) -> bool:
	if not zona_generada(zona_id):
		return false

	var enemigos: Array = enemigos_por_zona[zona_id]

	if enemigos.is_empty():
		return false

	for enemigo in enemigos:
		if not enemigo.get("derrotado", false):
			return false

	return true
	


func jefe_derrotado(zona_id: String, jefe_id: String) -> bool:
	if jefe_id.strip_edges().is_empty():
		push_error("EstadoExpedicion: no se puede consultar un jefe sin ID.")
		return false
		
	var jefes: Dictionary = jefes_derrotados_por_zona.get(zona_id, {})
	return jefes.get(jefe_id, false)


func marcar_jefe_derrotado(zona_id: String, jefe_id: String) -> void:
	if jefe_id.strip_edges().is_empty():
		push_error("EstadoExpedicion: no se puede marcar un jefe derrotado sin ID.")
		return
	
	if not jefes_derrotados_por_zona.has(zona_id):
		jefes_derrotados_por_zona[zona_id] = {}

	jefes_derrotados_por_zona[zona_id][jefe_id] = true
	
	
func crear_datos_guardado() -> ExpedicionSaveData:
	var datos_guardado := ExpedicionSaveData.new()

	for zona_id in enemigos_por_zona:
		var enemigos_serializados: Array[Dictionary] = []

		for enemigo in enemigos_por_zona[zona_id]:
			var enemy_data: EnemyData = enemigo.get("enemy_data")

			if enemy_data == null:
				push_error("El enemigo %s no tiene EnemyData." % enemigo.get("id", ""))
				return null

			if enemy_data.resource_path.is_empty() or enemy_data.resource_path.contains("::"):
				push_error(
					"El enemigo %s necesita un EnemyData guardado como recurso independiente."
					% enemigo.get("id", "")
				)
				return null

			enemigos_serializados.append({
				"id": enemigo["id"],
				"enemy_path": enemy_data.resource_path,
				"posicion": enemigo["posicion"],
				"derrotado": enemigo.get("derrotado", false)
			})

		datos_guardado.enemigos_por_zona[zona_id] = enemigos_serializados

	datos_guardado.jefes_derrotados_por_zona = jefes_derrotados_por_zona.duplicate(true)

	return datos_guardado
	
	
func cargar_datos_guardado(datos: ExpedicionSaveData) -> bool:
	if datos == null:
		push_error("No se recibieron datos de expedición.")
		return false

	var enemigos_restaurados: Dictionary = {}

	for zona_id in datos.enemigos_por_zona:
		var enemigos_zona: Array[Dictionary] = []

		for enemigo in datos.enemigos_por_zona[zona_id]:
			var ruta: String = enemigo.get("enemy_path", "")
			var recurso := ResourceLoader.load(ruta)

			if not recurso is EnemyData:
				push_error("No se pudo cargar EnemyData: %s" % ruta)
				return false

			enemigos_zona.append({
				"id": enemigo["id"],
				"enemy_data": recurso,
				"posicion": enemigo["posicion"],
				"derrotado": enemigo.get("derrotado", false)
			})

		enemigos_restaurados[zona_id] = enemigos_zona

	enemigos_por_zona = enemigos_restaurados
	jefes_derrotados_por_zona = datos.jefes_derrotados_por_zona.duplicate(true)

	return true
