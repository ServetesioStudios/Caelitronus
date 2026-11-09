extends Node2D

@export var jugador: CharacterBody2D
@export var escena_enemigo_mundo: PackedScene
@export var zona_id: String = "zona_roja"


func _ready() -> void:
	await get_tree().physics_frame
	generar_jefes()


func generar_jefes() -> void:
	if escena_enemigo_mundo == null:
		push_error("GeneradorJefes: falta asignar EnemigoMundo.tscn.")
		return

	if not GameManager.estado_expedicion.todos_enemigos_derrotados(zona_id):
		print("GeneradorJefes: todavía quedan enemigos en ", zona_id)
		return

	for nodo in get_children():
		if not nodo is MarcadorJefe:
			continue

		var marcador := nodo as MarcadorJefe

		if not marcador.habilitado:
			continue

		if marcador.jefe_id.strip_edges().is_empty():
			push_error("GeneradorJefes: marcador sin ID.")
			continue

		if marcador.enemy_data == null:
			push_error("GeneradorJefes: falta EnemyData en %s." % marcador.jefe_id)
			continue

		if GameManager.estado_expedicion.jefe_derrotado(zona_id, marcador.jefe_id):
			continue

		var jefe := escena_enemigo_mundo.instantiate() as EnemigoMundo

		if jefe == null:
			push_error("GeneradorJefes: la escena no contiene un EnemigoMundo válido.")
			continue

		add_child(jefe)
		jefe.global_position = marcador.global_position
		jefe.configurar(marcador.enemy_data, marcador.jefe_id)

		print("GeneradorJefes: jefe generado: ", marcador.jefe_id)
		
		jefe.interaccion_solicitada.connect(_on_jefe_interaccion_solicitada)
		

func _on_jefe_interaccion_solicitada(jefe: EnemigoMundo) -> void:
	if jefe.enemy_data == null:
		push_error("GeneradorJefes: el jefe no tiene EnemyData.")
		return

	if not is_instance_valid(jugador):
		push_error("GeneradorJefes: falta la referencia al jugador.")
		return

	if jefe.enemy_data.escena_combate == null:
		push_error("GeneradorJefes: %s no tiene escena de combate." % jefe.enemy_data.nombre)
		return

	GameManager.preparar_encuentro(
		jefe.enemy_data,
		zona_id,
		jefe.enemigo_id,
		jugador.global_position,
		GameManager.TipoEncuentro.JEFE
	)


	print("GeneradorJefes: iniciando combate contra ", jefe.enemy_data.nombre)

	SceneManager.change_scene(SceneManager.SceneID.BATALLA)
