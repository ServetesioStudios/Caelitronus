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
