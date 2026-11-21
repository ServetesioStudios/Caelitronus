class_name CardData
extends Resource

enum TipoObjetivo {
	PROPIO,
	ENEMIGO_FIJO,
	ENEMIGO_CUALQUIERA,
	LIBRE,
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
@export var costo_eter: CardCostData
