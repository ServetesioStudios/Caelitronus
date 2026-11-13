@tool
extends Node

@export_group("Referencias")
@export var suelo: TileMapLayer

@export_group("Dimensiones")
@export_range(1, 512, 1) var ancho: int = 64
@export_range(1, 512, 1) var alto: int = 48

@export_group("Configuración del TileSet")
@export var source_id: int = 0
@export var atlas_coords: Vector2i = Vector2i(0, 0)

@export_tool_button("Generar suelo")
var generar = generar_suelo


func generar_suelo() -> void:
	if suelo == null:
		push_error("Asigná el TileMapLayer Suelo.")
		return

	if ancho <= 0 or alto <= 0:
		push_error("Las dimensiones deben ser positivas.")
		return

	if suelo.tile_set == null:
		push_error("El suelo no tiene un TileSet asignado.")
		return

	# Verificar que exista el source_id.
	if not suelo.tile_set.has_source(source_id):
		push_error("El source_id no existe en el TileSet: %d" % source_id)
		return

	var source := suelo.tile_set.get_source(source_id)

	# Verificar que sea un atlas.
	if not source is TileSetAtlasSource:
		push_error("El source_id no corresponde a un TileSetAtlasSource.")
		return

	# Verificar que el tile exista.
	if not source.has_tile(atlas_coords):
		push_error(
			"El atlas no contiene un tile en las coordenadas: %s"
			% atlas_coords
		)
		return

	# Limpiar el suelo anterior.
	suelo.clear()

	# Generar el nuevo suelo.
	for y in range(alto):
		for x in range(ancho):
			suelo.set_cell(
				Vector2i(x, y),
				source_id,
				atlas_coords
			)

	# Actualizar el TileMapLayer.
	suelo.notify_runtime_tile_data_update()

	print(
		"Suelo generado correctamente: ",
		ancho,
		" x ",
		alto,
		" | Source: ",
		source_id,
		" | Atlas: ",
		atlas_coords
	)
