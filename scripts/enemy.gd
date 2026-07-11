class_name Enemy
extends CombatEntity

@export var enemy_data: EnemyData
@onready var intencion_texto = $Intencion

var intencion_actual: IntentData

func _ready():
	cargar_desde_data()
	actualizar_barra_vida()

func cargar_desde_data():
	if enemy_data == null:
		push_error("Enemy: falta asignar enemy_data en el Inspector")
		return
	nombre = enemy_data.nombre
	aplicar_stats(enemy_data.stats.duplicate())
	if has_node("Sprite2D") and enemy_data.sprite != null:
		$Sprite2D.texture = enemy_data.sprite

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
