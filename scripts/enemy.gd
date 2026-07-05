class_name Enemy
extends CombatEntity

@export var enemy_data: EnemyData

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
