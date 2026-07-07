class_name IntentData
extends Resource

enum Tipo {ATACAR, DEFENDER, HABILIDAD}

@export var tipo: Tipo = Tipo.ATACAR
@export var valor: int = 0 
@export var icono: Texture2D
