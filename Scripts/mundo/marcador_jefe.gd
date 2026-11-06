extends Marker2D
class_name MarcadorJefe

@export_group("Identificación")
@export var jefe_id: String = ""
@export var habilitado: bool = true

@export_group("Configuración del jefe")
@export var enemy_data: EnemyData
