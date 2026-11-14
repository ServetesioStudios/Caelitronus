class_name CardData
extends Resource

enum TipoObjetivo {
	PROPIO,               # escudo: siempre te lo aplicás a vos, sin importar dónde soltás
	ENEMIGO_FIJO,         # ataques que siempre pegan al mismo enemigo (ej. "el del frente")
	ENEMIGO_CUALQUIERA,   # tenés que soltar sobre un enemigo específico para elegir cuál
	LIBRE,                # podés soltarla sobre vos o sobre cualquier enemigo
}

@export_group("Información")
@export var nombre: String
@export_multiline var descripcion: String
@export var arte: Texture2D

@export_group("Combate")
@export var efectos: Array[EffectData] = []
@export var animacion: String = ""
@export var tipo_objetivo: TipoObjetivo = TipoObjetivo.ENEMIGO_CUALQUIERA

@export_group("Costo de carta")
@export var costo: int = 1 # Temporal: energía anterior
@export var costo_eter: CardCostData


func jugar(fuente: CombatEntity, objetivo: CombatEntity) -> void:
	for efecto in efectos:
		efecto.aplicar(fuente, objetivo)
