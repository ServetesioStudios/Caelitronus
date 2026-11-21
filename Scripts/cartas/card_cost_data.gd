class_name CardCostData
extends Resource

@export_group("Éteres genéricos")
@export_range(0, 2, 1) var generico: int = 0

@export_group("Éteres específicos")
@export_range(0, 1, 1) var rojo: int = 0
@export_range(0, 1, 1) var violeta: int = 0
@export_range(0, 1, 1) var verde: int = 0
@export_range(0, 1, 1) var rosa: int = 0
@export_range(0, 1, 1) var celeste: int = 0


func obtener_costos_especificos() -> Array[int]:
	return [
		rojo,
		violeta,
		verde,
		rosa,
		celeste
	]


func obtener_costo_total() -> int:
	var total: int = generico

	for cantidad in obtener_costos_especificos():
		total += cantidad

	return total


func es_costo_valido() -> bool:
	if generico < 0 or generico > 2:
		return false

	var total: int = generico

	for cantidad in obtener_costos_especificos():
		if cantidad < 0 or cantidad > 1:
			return false

		total += cantidad

	return total <= 2
