class_name PlayerData
extends Resource

@export var tipo_caelius: GameManager.TipoCaelius = GameManager.TipoCaelius.PENA
@export var nivel: int = 1
@export var gold: int = 0
@export var hp_actual: int = -1 
@export var deck: Array[CardData] = []

@export var jefes_derrotados: Dictionary = {
	GameManager.Jefe.ESPINA: false,
	GameManager.Jefe.SERPICO: false,
	GameManager.Jefe.EIRENE: false,
	GameManager.Jefe.CORVUS: false,
	GameManager.Jefe.GALAAD: false,
	GameManager.Jefe.KAPPARAH: false,
}
