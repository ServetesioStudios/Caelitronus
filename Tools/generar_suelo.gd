@tool
extends Node

@export var suelo: TileMapLayer

@export var ancho: int = 128
@export var alto: int = 96

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

	var source := suelo.tile_set.get_source(source_id)

	if not source is TileSetAtlasSource:
		push_error("El source_id no corresponde a un atlas.")
		return

	if not source.has_tile(atlas_coords):
		push_error("Las coordenadas no corresponden a un tile válido.")
		return

	suelo.clear()

	for y in range(alto):
		for x in range(ancho):
			suelo.set_cell(
				Vector2i(x, y),
				source_id,
				atlas_coords
			)

	print("Suelo generado: ", ancho, " x ", alto)
