extends Node2D

@onready var combat_manager := $CombatManager
@onready var deck_manager := $DeckManager
@onready var btn_fin_turno := $CanvasLayer/BtnFinTurno

@onready var player = $CanvasLayer/player
@onready var enemy = $CanvasLayer/enemy

@onready var texto_combate = $CanvasLayer/textocombate
@onready var texto_stats_player = $CanvasLayer/playerstatstex
@onready var texto_stats_enemy = $CanvasLayer/enemiplayetex

var historial_texto = ""
var max_lineas = 18

func _ready():
	var enemigos: Array[Enemy] = [enemy]

	var mazo_prueba: Array[CardData] = []
	for i in 5:
		mazo_prueba.append(load("res://Data/cartas/golpe.tres"))
	for i in 5:
		mazo_prueba.append(load("res://Data/cartas/bloqueo.tres"))
	deck_manager.iniciar_mazo(mazo_prueba)
	
	var mazo_inicial = ""
	for carta in mazo_prueba:
		mazo_inicial += " %s," %carta.nombre
	print(mazo_inicial)

	combat_manager.turno_jugador_iniciado.connect(deck_manager.iniciar_turno)
	combat_manager.turno_jugador_iniciado.connect(func(): print("Turno del jugador"))
	combat_manager.turno_enemigo_iniciado.connect(func(): print("Turno del enemigo"))
	
	combat_manager.intencion_actualizada.connect(_debug_mostrar_intencion)
	
	combat_manager.combate_terminado.connect(_on_combate_terminado)
	deck_manager.mano_actualizada.connect(_debug_mostrar_mano)
	btn_fin_turno.pressed.connect(combat_manager.finalizar_turno_jugador)
	combat_manager.iniciar_combate(player, enemigos)

func _debug_mostrar_mano(mano: Array[CardData]) -> void:
	print("--- MANO ACTUAL (%d cartas) ---" % mano.size())
	for carta in mano:
		print(" - %s (costo %d)" % [carta.nombre, carta.costo])

func _on_combate_terminado(victoria: bool):
	if victoria:
		print("¡Ganaste!")
	else:
		print("Perdiste")

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

func actualizar_stats_ui() -> void:
	if is_instance_valid(player):
		texto_stats_player.text = "ATQ= %s     VEL= %s     PODER= %s\nDEF= %s     ESQ= %s     FE= %s" % [
			player.daño, player.velocidad, player.poder, player.defensa, player.esquive, player.fe
		]
	if is_instance_valid(enemy):
		texto_stats_enemy.text = "ATQ= %s     VEL= %s     PODER= %s\nDEF= %s     ESQ= %s     FE= %s" % [
			enemy.daño, enemy.velocidad, enemy.poder, enemy.defensa, enemy.esquive, enemy.fe
		]

func animar_ataque(atacante: CombatEntity) -> void:
	if !is_instance_valid(atacante):
		return
	var tween = create_tween()
	var posicion_original = atacante.position
	var distancia = 40
	var posicion_ataque = posicion_original + (Vector2(distancia, 0) if atacante == player else Vector2(-distancia, 0))
	tween.tween_property(atacante, "position", posicion_ataque, 0.1)
	tween.tween_property(atacante, "position", posicion_original, 0.1)

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
	
	mostrar_texto("%s juega %s" % [player.nombre, carta.nombre]) 
	
	_debug_estado_combate()
	if combat_manager.verificar_fin_combate():
		return
		
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and combat_manager.es_turno_jugador():
		if deck_manager.mano.size() > 0:
			intentar_jugar_carta(deck_manager.mano[0], enemy)

func _debug_estado_combate():
	print("Player HP: %d/%d | Player DEF: %d | Energía: %d/%d | Enemy HP: %d/%d" % [
		player.hp, player.max_hp,
		player.defensa,
		player.energia_actual, player.energia_maxima,
		enemy.hp, enemy.max_hp
	])			

func _debug_mostrar_intencion(enemigo: Enemy):
	print("%s va a: %s (%d)" % [enemigo.nombre, IntentData.Tipo.keys()[enemigo.intencion_actual.tipo], enemigo.intencion_actual.valor])
