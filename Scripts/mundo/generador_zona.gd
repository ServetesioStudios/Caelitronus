
extends Node

@export var areas_aparicion: Node2D
@export var contenedor_enemigos: Node2D

const MARGEN: float = 8.0
const MAX_INTENTOS: int = 100


func _ready() -> void:
	generar_enemigos()


func generar_enemigos() -> void:
	if areas_aparicion == null or contenedor_enemigos == null:
		push_error("Generador: faltan referencias a los nodos.")
		return

	for area in areas_aparicion.get_children():
		if not area is AreaAparicion:
			continue

		if not area.habilitada:
			continue

		generar_area(area)


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

				if separacion_correcta:
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

			crear_marcador(
				configuracion.enemy_data,
				posicion
			)

			print(
				"[%s] %s generado en %s" % [
					area.area_id,
					configuracion.enemy_data.nombre,
					posicion
				]
			)


func crear_marcador(datos: EnemyData, posicion: Vector2) -> void:
	var marcador := Node2D.new()
	marcador.name = datos.nombre

	contenedor_enemigos.add_child(marcador)
	marcador.global_position = posicion

	var cuadrado := Polygon2D.new()

	cuadrado.polygon = PackedVector2Array([
		Vector2(-8, -8),
		Vector2(8, -8),
		Vector2(8, 8),
		Vector2(-8, 8)
	])

	cuadrado.color = Color(0.9, 0.3, 0.3)

	marcador.add_child(cuadrado)
