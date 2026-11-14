class_name EtherColors
extends RefCounted

# ============================================================
# COLORES DE ÉTER
# ============================================================

const ROJO := Color("#C83B3B")
const VIOLETA := Color("#874FC4")
const VERDE := Color("#3E9D65")
const ROSA := Color("#DD79AA")
const CELESTE := Color("#59B8D8")

# ============================================================
# COLORES ESPECIALES
# ============================================================

const GENERICO := Color("#D9DDE2")
const VACIO := Color("#303030")

# ============================================================
# LISTA DE COLORES
# Orden: rojo, violeta, verde, rosa, celeste
# ============================================================

const COLORES: Array[Color] = [
	ROJO,
	VIOLETA,
	VERDE,
	ROSA,
	CELESTE
]


# ============================================================
# OBTENER COLOR POR ÍNDICE
# ============================================================

static func obtener_color(indice: int) -> Color:
	if indice < 0 or indice >= COLORES.size():
		return VACIO

	return COLORES[indice]
