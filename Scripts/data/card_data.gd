class_name CardData
extends Resource

enum TipoObjetivo {
	PROPIO,               # escudo: siempre te lo aplicás a vos, sin importar dónde soltás
	ENEMIGO_FIJO,         # ataques que siempre pegan al mismo enemigo (ej. "el del frente")
	ENEMIGO_CUALQUIERA,   # tenés que soltar sobre un enemigo específico para elegir cuál
	LIBRE,                # podés soltarla sobre vos o sobre cualquier enemigo
}

@export var nombre: String
@export_multiline var descripcion: String
@export var efectos: Array[EffectData] = []
@export var animacion: String = ""
@export var tipo_objetivo: TipoObjetivo = TipoObjetivo.ENEMIGO_CUALQUIERA
@export var costo: int = 1
@export var arte: Texture2D


func jugar(fuente: CombatEntity, objetivo: CombatEntity) -> void:
	for efecto in efectos:
		efecto.aplicar(fuente, objetivo)
