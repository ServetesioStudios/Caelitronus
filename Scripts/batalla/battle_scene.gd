extends Node2D

@onready var combat_manager := $CombatManager
@onready var deck_manager := $DeckManager
@onready var btn_fin_turno := $CanvasLayer/BtnFinTurno

@onready var player = $CanvasLayer/player
@onready var enemy = $CanvasLayer/enemy

@onready var texto_combate = $CanvasLayer/textocombate
@onready var texto_stats_player = $CanvasLayer/playerstatstex
@onready var texto_stats_enemy = $CanvasLayer/enemiplayetex
@onready var label_energia = $CanvasLayer/LabelEnergia
@onready var mano_ui := $CanvasLayer/Mano


var historial_texto = ""
var max_lineas = 18

func _ready():
	for zona in get_tree().get_nodes_in_group("DropZones"):
		zona.carta_soltada.connect(intentar_jugar_carta)
	
	var enemigos: Array[Enemy] = [enemy]
		
	deck_manager.iniciar_mazo(_crear_mazo_inicial())
	mano_ui.player_ref = player 
	deck_manager.mano_actualizada.connect(mano_ui.mostrar_mano)
	
	combat_manager.turno_jugador_iniciado.connect(deck_manager.iniciar_turno)
	combat_manager.turno_jugador_iniciado.connect(func(): btn_fin_turno.disabled = false)
	combat_manager.turno_enemigo_iniciado.connect(func(): btn_fin_turno.disabled = true)
	combat_manager.combate_terminado.connect(_on_combate_terminado)
	
	combat_manager.enemigo_actuo.connect(func(enemigo): enemigo.reproducir_animacion(enemigo.intencion_actual.tipo))
	combat_manager.accion_enemigo_realizada.connect(_on_accion_enemigo_realizada)
	
	player.energia_actualizada.connect(_actualizar_label_energia)
	player.energia_actualizada.connect(func(_a, _m): mano_ui.actualizar_disponibilidad_todas())
	
	btn_fin_turno.pressed.connect(combat_manager.finalizar_turno_jugador)
	
	combat_manager.iniciar_combate(player, enemigos)
	actualizar_stats_ui()

func mostrar_texto(texto: String) -> void:
	if texto_combate == null:
		return
	historial_texto += texto + "\n\n"
	var lineas = historial_texto.split("\n")
	if lineas.size() > max_lineas:
		var nuevas_lineas = []
		for i in range(lineas.size() - max_lineas, lineas.size()):
			nuevas_lineas.append(lineas[i])
		historial_texto = "\n".join(nuevas_lineas)
	texto_combate.text = historial_texto
	await get_tree().process_frame
	if is_instance_valid(texto_combate):
		texto_combate.scroll_to_line(texto_combate.get_line_count())

func _actualizar_label_energia(actual: int, maxima: int) -> void: 
	label_energia.text = "Energía: %d / %d" %[actual, maxima]

func actualizar_stats_ui() -> void:
	if is_instance_valid(player):
		texto_stats_player.text = "ATQ= %s     VEL= %s     PODER= %s\nDEF= %s     ESQ= %s     FE= %s\nBloqueo= %d     Sangrado= %d     Veneno= %d" % [
			player.daño, player.velocidad, player.poder, player.defensa, player.esquive, player.fe,
			player.bloqueo,
			player.estados.get(CombatEntity.TipoEstado.SANGRADO, 0),
			player.estados.get(CombatEntity.TipoEstado.VENENO, 0)
		]	
	if is_instance_valid(enemy):
		texto_stats_enemy.text = "ATQ= %s     VEL= %s     PODER= %s\nDEF= %s     ESQ= %s     FE= %s\nBloqueo= %d     Sangrado= %d     Veneno= %d" % [
			enemy.daño, enemy.velocidad, enemy.poder, enemy.defensa, enemy.esquive, enemy.fe,
			enemy.bloqueo,
			enemy.estados.get(CombatEntity.TipoEstado.SANGRADO, 0),
			enemy.estados.get(CombatEntity.TipoEstado.VENENO, 0)
		]


func _crear_mazo_inicial() -> Array[CardData]:
	var mazo: Array[CardData] = []
	var ruta = "res://Data/cartas/"
	for i in 3: 
		mazo.append(load(ruta + "/golpe_basico.tres"))
	for i in 3:
		mazo.append(load(ruta + "/golpe_fuerte.tres"))
	for i in 2: 
		mazo.append(load(ruta+"/escudo.tres"))
	for i in 2: 
		mazo.append(load(ruta + "recuperar_energia.tres"))
	for i in 2: 
		mazo.append(load(ruta+"/sangrado.tres"))
	return mazo

func _debug_estado_combate():
	print("Player HP: %d/%d | Player DEF: %d | Energía: %d/%d | Enemy HP: %d/%d" % [
		player.hp, player.max_hp,
		player.defensa,
		player.energia_actual, player.energia_maxima,
		enemy.hp, enemy.max_hp
	])			

func intentar_jugar_carta(carta: CardData, objetivo: CombatEntity) -> void: 
	if not combat_manager.es_turno_jugador():
		print("No es tu turno")
		return
	if not player.puede_pagar(carta.costo):
		print("No tienes energía suficiente para %s" %carta.nombre)
		return
	
	player.gastar_energia(carta.costo)
	carta.jugar(player,objetivo)
	deck_manager.jugar_carta(carta)
	
	if carta.tipo_objetivo != carta.TipoObjetivo.PROPIO:
		player.reproducir_animacion(IntentData.Tipo.ATACAR)
	else:
		player.reproducir_animacion(IntentData.Tipo.DEFENDER)

	
	mostrar_texto("%s juega %s" % [player.nombre, carta.nombre]) 
	actualizar_stats_ui()
	_debug_estado_combate()
	if combat_manager.verificar_fin_combate():
		return

func _on_accion_enemigo_realizada(enemigo: Enemy, descripcion: String) -> void:
	mostrar_texto(descripcion)
	actualizar_stats_ui()

func _on_combate_terminado(victoria: bool):
	if victoria:
		print("¡Ganaste!")
	else:
		print("Perdiste")
