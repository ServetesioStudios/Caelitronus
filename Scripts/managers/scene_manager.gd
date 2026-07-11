extends Node

enum SceneID {
	MENU_PRINCIPAL,
	CINEMATICA_INICIO,
	SELECT_PERSONAJE,
	SELECT_NIVEL,
	SUBIR_NIVEL,
	BATALLA,
	AJUSTES,
	CREDITOS,
	GLOSARIO,
	FIN_PARTIDA,
	SALIR
}

const SCENE_PATHS := {
	SceneID.MENU_PRINCIPAL: "res://Scenes/menus/menu_principal.tscn",
	SceneID.SELECT_PERSONAJE: "res://Scenes/menus/select_personaje.tscn",
	SceneID.SELECT_NIVEL: "res://Scenes/menus/select_nivel.tscn",
	SceneID.BATALLA: "res://Scenes/battle_scene.tscn",
	SceneID.CINEMATICA_INICIO: "res://Scenes/cinematicas/cinematica_inicio.tscn",
	SceneID.AJUSTES: "res://Scenes/menus/ajustes.tscn",
	SceneID.CREDITOS: "res://Scenes/menus/creditos.tscn",
	SceneID.SALIR: "res://Scenes/menus/salir.tscn",
	SceneID.SUBIR_NIVEL: "res://Scenes/subir_nivel.tscn",
	SceneID.GLOSARIO: "res://Scenes/menus/glosario.tscn", 
	SceneID.FIN_PARTIDA: "res://Scenes/menus/fin_partida.tscn"
}

func change_scene(id: SceneID) -> void:
	var path: String = SCENE_PATHS.get(id, "")
	if path == "":
		push_error("SceneManager: no hay path registrado para el ID %s" % SceneID.keys()[id])
		return
	
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("SceneManager: fallo al cargar %s (error %s)" % [path, err])
		
func add_overlay(id: SceneID, parent: Node) -> Node:
	var path: String = SCENE_PATHS.get(id, "")
	if path == "":
		push_error("SceneManager: no hay path registrado para el ID %s" % SceneID.keys()[id])
		return null

	var scene_resource: PackedScene = load(path)
	
	if scene_resource == null:
		push_error("SceneManager: fallo al cargar %s" % path)
		return null
		
	for child in parent.get_children():
		if child.scene_file_path == path:
			return child 

	var instance := scene_resource.instantiate()
	parent.add_child(instance)
	return instance
