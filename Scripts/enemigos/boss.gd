extends Enemy
class_name Boss

@export var nombre_habilidad: String = "Éxtasis Prohibido"
@export var cooldown_turnos: int = 3
@export var duracion_buff_turnos: int = 2
@export var bonus_daño_habilidad: float = 1.3
@export var veneno_aplicado: int = 3
@export var umbral_fase_desesperacion: float = 0.25
@export var bonus_daño_fase_desesperacion: float = 1.2

var turnos_restantes_cooldown: int = 0
var turnos_restantes_buff: int = 0
var fase_desesperacion: bool = false

func decidir_intencion() -> void:
	var nueva_intencion := IntentData.new()
	if turnos_restantes_cooldown <= 0:
		nueva_intencion.tipo = IntentData.Tipo.HABILIDAD
		nueva_intencion.valor = veneno_aplicado
	else:
		var accion = randi() % 2
		match accion:
			0:
				nueva_intencion.tipo = IntentData.Tipo.ATACAR
				nueva_intencion.valor = daño
			1:
				nueva_intencion.tipo = IntentData.Tipo.DEFENDER
				nueva_intencion.valor = 5
	intencion_actual = nueva_intencion

func activar_habilidad() -> void:
	super()
	habilidad_nombre = nombre_habilidad
	bonus_daño = bonus_daño_habilidad
	turnos_restantes_buff = duracion_buff_turnos
	turnos_restantes_cooldown = cooldown_turnos

func aplicar_efecto_habilidad_a_objetivo(objetivo: CombatEntity) -> void:
	objetivo.aplicar_estado(CombatEntity.TipoEstado.VENENO, veneno_aplicado)

func procesar_estados() -> void:
	super.procesar_estados()

	if turnos_restantes_cooldown > 0:
		turnos_restantes_cooldown -= 1

	if turnos_restantes_buff > 0:
		turnos_restantes_buff -= 1
		if turnos_restantes_buff <= 0:
			bonus_daño = 1.0

	if not fase_desesperacion and hp <= max_hp * umbral_fase_desesperacion:
		fase_desesperacion = true
		bonus_daño *= bonus_daño_fase_desesperacion
		color_base = Color(1.0, 0.7, 0.8, 1.0)
		self.modulate = color_base
