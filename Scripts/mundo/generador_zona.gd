
extends Node

@export var areas_aparicion: Node2D
@export var contenedor_enemigos: Node2D
@export var escena_enemigo_mundo: PackedScene
@export var jugador: CharacterBody2D
@export var zona_id: String = "zona_roja"

var enemigos_generados: Array[Dictionary] = []

const MARGEN: float = 8.0
const MAX_INTENTOS: int = 100
const CAPA_OBSTACULOS: int = 1
const TAMANO_MARCADOR := Vector2(16.0, 16.0)


func _ready() -> void:
	await get_tree().physics_frame

	if GameManager.zona_id_encuentro == zona_id:
		if is_instance_valid(jugador):
			jugador.global_position = GameManager.posicion_jugador_encuentro
			GameManager.limpiar_encuentro()
		else:
			push_error("Generador: no se pudo restaurar la posición del jugador.")

	generar_enemigos()


func generar_enemigos() -> void:
	if areas_aparicion == null or contenedor_enemigos == null:
		push_error("Generador: faltan referencias a los nodos.")
		return
		
	if escena_enemigo_mundo == null:
		push_error("Generador: falta asignar EnemigoMundo.tscn.")
		return
		
	if GameManager.estado_expedicion.zona_generada(zona_id):
		restaurar_enemigos()
		return
		
	enemigos_generados.clear()

	for area in areas_aparicion.get_children():
		if not area is AreaAparicion:
			continue

		if not area.habilitada:
			continue

		generar_area(area)
		
	GameManager.estado_expedicion.guardar_enemigos(
		zona_id,
		enemigos_generados
	)


func generar_area(area: AreaAparicion) -> void:
	var colision := area.get_node_or_null(
        "CollisionShape2D"
	) as CollisionShape2D

	if colision == null or not colision.shape is RectangleShape2D:
		push_warning("Área sin rectángulo válido: %s" % area.area_id)
		return

	var rectangulo := colision.shape as RectangleShape2D
	var mitad := rectangulo.size / 2.0
	var limite := mitad - Vector2(MARGEN, MARGEN)

	if limite.x <= 0.0 or limite.y <= 0.0:
		push_warning("Área demasiado pequeña: %s" % area.area_id)
		return

	var posiciones: Array[Vector2] = []
	var indice_enemigo: int = 0

	for configuracion in area.enemigos:
		if configuracion == null or configuracion.enemy_data == null:
			continue

		for i in range(configuracion.cantidad):
			var encontrada := false
			var posicion := Vector2.ZERO

			for intento in range(MAX_INTENTOS):
				var posicion_local := Vector2(
					randf_range(-limite.x, limite.x),
					randf_range(-limite.y, limite.y)
				)

				posicion = colision.to_global(posicion_local)

				var separacion_correcta := true

				for anterior in posiciones:
					if posicion.distance_to(anterior) < area.separacion_minima:
						separacion_correcta = false
						break

				if separacion_correcta and posicion_libre_de_obstaculos(posicion):
					encontrada = true
					break

			if not encontrada:
				push_warning(
					"No se pudo generar %s en %s" % [
						configuracion.enemy_data.nombre,
						area.area_id
					]
				)
				continue

			posiciones.append(posicion)


			var enemigo_id := "%s_%d" % [area.area_id, indice_enemigo]
			
			crear_enemigo_mundo(
				configuracion.enemy_data,
				posicion, 
				enemigo_id
			)
			
			enemigos_generados.append({
				"id": enemigo_id,
				"enemy_data": configuracion.enemy_data,
				"posicion": posicion,
				"derrotado": false
			})

			indice_enemigo += 1


			print(
				"[%s] %s generado en %s" % [
					area.area_id,
					configuracion.enemy_data.nombre,
					posicion
				]
			)


func posicion_libre_de_obstaculos(posicion: Vector2) -> bool:
	var forma := RectangleShape2D.new()
	forma.size = TAMANO_MARCADOR

	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma
	consulta.transform = Transform2D(0.0, posicion)
	consulta.collision_mask = CAPA_OBSTACULOS
	consulta.collide_with_bodies = true #StaticBody2D
	consulta.collide_with_areas = false #Area2D
	
	var espacio := areas_aparicion.get_world_2d().direct_space_state
	var resultados := espacio.intersect_shape(consulta, 1)
	
	return resultados.is_empty()


func crear_enemigo_mundo(datos: EnemyData, posicion: Vector2, id: String) -> void:
	if escena_enemigo_mundo == null:
		push_error("Generador: falta asignar la escena del enemigo de mundo.")
		return

	var enemigo := escena_enemigo_mundo.instantiate() as EnemigoMundo

	if enemigo == null:
		push_error("Generador: la escena no contiene un EnemigoMundo válido.")
		return

	contenedor_enemigos.add_child(enemigo)
	enemigo.global_position = posicion
	enemigo.configurar(datos, id)
	
	enemigo.interaccion_solicitada.connect(
		_on_enemigo_interaccion_solicitada
	)


func restaurar_enemigos() -> void: 
	var enemigos_guardados:= GameManager.estado_expedicion.obtener_enemigos(zona_id)
	
	for datos_enemigo in enemigos_guardados:
		if datos_enemigo["derrotado"]:
			continue
		
		var datos: EnemyData = datos_enemigo["enemy_data"]
		var posicion: Vector2 = datos_enemigo["posicion"]
		var id: String = datos_enemigo["id"]

		crear_enemigo_mundo(datos, posicion, id)

	print("Generador: enemigos restaurados en %s" % zona_id)
	


func _on_enemigo_interaccion_solicitada(enemigo: EnemigoMundo) -> void:
	if enemigo.enemy_data == null:
		push_error("Generador: el enemigo no tiene EnemyData.")
		return
	
	if not is_instance_valid(jugador):
		push_error("Generador: falta la referencia al jugador.")
		return

	if enemigo.enemy_data.escena_combate == null:
		push_error(
			"Generador: %s no tiene escena de combate." %
			enemigo.enemy_data.nombre
		)
		return

	GameManager.preparar_encuentro(
		enemigo.enemy_data,
		zona_id,
		enemigo.enemigo_id,
		jugador.global_position
	)


	print("Zona: ", GameManager.zona_id_encuentro)
	print("Enemigo: ", GameManager.enemigo_id_encuentro)
	print("Posición jugador: ", GameManager.posicion_jugador_encuentro)

	SceneManager.change_scene(SceneManager.SceneID.BATALLA)
