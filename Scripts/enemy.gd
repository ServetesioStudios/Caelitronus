class_name Enemy
extends CombatEntity

@export var enemy_data: EnemyData
@onready var intencion_texto = $Intencion

var intencion_actual: IntentData

func _ready() -> void:
	if enemy_data == null:
		push_error("Enemy: no se asignó EnemyData antes de inicializar el enemigo")
		return

	cargar_desde_data()
	actualizar_barra_vida()

func configurar(datos: EnemyData) -> void:
	enemy_data = datos


func cargar_desde_data() -> void:
	if enemy_data == null:
		push_error("Enemy: faltan datos del enemigo")
		return

	if enemy_data.stats == null:
		push_error("Enemy: faltan estadísticas para %s" % enemy_data.nombre)
		return

	nombre = enemy_data.nombre
	aplicar_stats(enemy_data.stats.duplicate())


func decidir_intencion() -> void:
	var nueva_intencion := IntentData.new()
	var accion = randi() % 2
	match accion:
		0:
			nueva_intencion.tipo = IntentData.Tipo.ATACAR
			nueva_intencion.valor = daño

		1:
			nueva_intencion.tipo = IntentData.Tipo.DEFENDER
			nueva_intencion.valor = 5
	intencion_actual = nueva_intencion
	
func actualizar_intencion_ui() -> void:
	match intencion_actual.tipo:
		IntentData.Tipo.ATACAR:
			intencion_texto.text = "Ataque * %s" %str(intencion_actual.valor)
		IntentData.Tipo.DEFENDER:
			intencion_texto.text = "Defensa * %s" %str(intencion_actual.valor)
		IntentData.Tipo.HABILIDAD:
			intencion_texto.text = "Habilidad * %s" %str(intencion_actual.valor)

func al_atacar() -> void: 
	pass

func aplicar_efecto_habilidad_a_objetivo(objetivo: CombatEntity) -> void:
	pass
	
func activar_habilidad() -> void:
	super()
	
	
func obtener_nombre_animacion_intencion() -> String:
	if intencion_actual.animacion != "":
		return intencion_actual.animacion
	match intencion_actual.tipo:
		IntentData.Tipo.ATACAR:
			return "ataque"
		IntentData.Tipo.DEFENDER:
			return "bloqueo"
	return ""
