class_name EstadoEffectData
extends EffectData

@export var tipo: CombatEntity.TipoEstado
@export var cantidad: int = 2
@export var aplicar_a_uno_mismo: bool = false

func aplicar(fuente: CombatEntity, objetivo: CombatEntity) -> void: 
	var destino = fuente if aplicar_a_uno_mismo else objetivo
	destino.aplicar_estado(tipo, cantidad)
