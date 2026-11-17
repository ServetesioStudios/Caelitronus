class_name EsquiveBuffEffectData
extends EffectData

@export var cantidad: int = 5
@export var duracion_turnos: int = 3
@export var aplicar_a_uno_mismo: bool = true

func aplicar(fuente: CombatEntity, objetivo: CombatEntity) -> void: 
	var destino = fuente if aplicar_a_uno_mismo else objetivo
	destino.esquive_buff_valor = cantidad
	destino.esquive_buff_turnos = duracion_turnos
