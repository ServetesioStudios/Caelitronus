class_name EtherProfileData
extends Resource

@export_group("Pesos de éter")

@export_range(0, 100, 1) var rojo: int = 10
@export_range(0, 100, 1) var violeta: int = 10
@export_range(0, 100, 1) var verde: int = 10
@export_range(0, 100, 1) var rosa: int = 10
@export_range(0, 100, 1) var celeste: int = 10


func obtener_pesos() -> Array[int]:
	return [
		rojo,
		violeta,
		verde,
		rosa,
		celeste
	]


func obtener_peso_total() -> int:
	var total: int = 0

	for peso in obtener_pesos():
		total += peso

	return total


func es_valido() -> bool:
	return obtener_peso_total() > 0
