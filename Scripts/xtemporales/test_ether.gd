extends Node

@onready var ether_manager: EtherManager = $EtherManager

const PERFIL_PRUEBA := preload(
	"res://Data/characters/ether_profiles/ether_ira.tres"
)


func _ready() -> void:
	ether_manager.iniciar_combate(PERFIL_PRUEBA)

	print("=== INICIO DEL COMBATE ===")
	print("Repeticiones: ", ether_manager.repeticiones_restantes)

	ether_manager.iniciar_turno()

	print("Éteres iniciales: ", ether_manager.eteres)

	var indices: Array[int] = [0, 2, 4]

	var resultado: bool = ether_manager.repetir_eteres(indices)

	print("Repetición exitosa: ", resultado)
	print("Éteres después de repetir: ", ether_manager.eteres)
	print("Repeticiones restantes: ", ether_manager.repeticiones_restantes)

	ether_manager.finalizar_turno()

	print("Éteres al finalizar turno: ", ether_manager.eteres)

	ether_manager.iniciar_turno()

	print("Éteres del siguiente turno: ", ether_manager.eteres)
	print("Repeticiones restantes: ", ether_manager.repeticiones_restantes)
	
	probar_costos()
	probar_pagos()
	probar_consumo()
	
	
	
func probar_costos() -> void:
	print("\n=== PRUEBAS DE COSTOS ===")

	var costo := CardCostData.new()

	# Prueba 1: un éter genérico
	costo.generico = 1
	print("Genérico simple: ", costo.es_costo_valido())

	# Prueba 2: dos colores diferentes
	costo.generico = 0
	costo.rojo = 1
	costo.violeta = 1
	print("Mixto rojo + violeta: ", costo.es_costo_valido())

	# Prueba 3: específico + genérico
	costo.violeta = 0
	costo.generico = 1
	print("Rojo + genérico: ", costo.es_costo_valido())

	# Prueba 4: coste superior al máximo
	costo.violeta = 1
	print("Tres éteres: ", costo.es_costo_valido())

	# Prueba 5: dos del mismo color específico
	costo.generico = 0
	costo.violeta = 0
	costo.rojo = 2
	print("Dos rojos: ", costo.es_costo_valido())
	
	
func probar_pagos() -> void:
	print("\n=== PRUEBAS DE PAGO ===")

	ether_manager.eteres = [0, 1, 2, 3, 4]

	var costo := CardCostData.new()

	# Prueba 1: rojo
	costo.rojo = 1
	print("Rojo disponible: ", ether_manager.puede_pagar(costo))

	# Prueba 2: dos colores diferentes
	costo.violeta = 1
	print("Rojo + violeta: ", ether_manager.puede_pagar(costo))

	# Prueba 3: rojo + genérico
	costo.violeta = 0
	costo.generico = 1
	print("Rojo + genérico: ", ether_manager.puede_pagar(costo))

	# Prueba 4: color que no tenemos
	ether_manager.eteres = [0, 0, 0, 0, 0]
	costo.rojo = 0
	costo.generico = 0
	costo.verde = 1
	print("Verde no disponible: ", ether_manager.puede_pagar(costo))

	# Prueba 5: rojo + genérico sin otro éter
	ether_manager.eteres = [0, -1, -1, -1, -1]
	costo.verde = 0
	costo.rojo = 1
	costo.generico = 1
	print("Rojo sin genérico adicional: ", ether_manager.puede_pagar(costo))

func probar_consumo() -> void:
	print("\n=== PRUEBAS DE CONSUMO ===")

	# Posiciones: 0, 1, 2, 3, 4
	ether_manager.eteres = [0, 1, 0, 3, 4]

	var costo := CardCostData.new()
	costo.rojo = 1
	costo.generico = 1

	print("Éteres iniciales: ", ether_manager.eteres)
	print("Puede pagar: ", ether_manager.puede_pagar(costo))
	print(
		"Índices específicos: ",
		ether_manager.obtener_indices_especificos(costo)
	)

	# Seleccionamos el violeta de la posición 1
	var genericos: Array[int] = [1]

	var resultado: bool = ether_manager.pagar_carta(
		costo,
		genericos
	)

	print("Pago exitoso: ", resultado)
	print("Éteres restantes: ", ether_manager.eteres)

	# Intentamos usar dos veces el mismo espacio.
	var segundo_pago: bool = ether_manager.pagar_carta(
		costo,
		genericos
	)

	print("Segundo pago inválido: ", segundo_pago)
	print("Éteres finales: ", ether_manager.eteres)
