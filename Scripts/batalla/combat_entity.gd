class_name CombatEntity
extends Node

enum TipoEstado { SANGRADO, VENENO }
var estados: Dictionary = {}
var esquive_buff_valor: int = 0
var esquive_buff_turnos: int = 0

var nombre: String
var stats: Stats

var hp: int
var max_hp: int

var daño: int
var defensa: int
var esquive: int
var velocidad: int
var fe: int
var poder: int

var bloqueo: int = 0

var bonus_daño := 1.0
var bonus_defensa := 1.0
var bonus_velocidad := 1.0

var robo_vida := false
var porcentaje_robo_vida := 0.5
var doble_golpe := false
var inmune := false

var base_tiempo_ataque := 0.0
var habilidad_activa := false
#var habilidad_timer := 0.0
var cooldown_habilidad := 0.0
var habilidad_nombre := ""

var tiempo_ataque := 0.0
var vida_tween = null
var color_base: Color = Color(1, 1, 1, 1)



func aplicar_stats(s: Stats) -> void:
	stats = s
	max_hp = s.max_hp
	hp = s.max_hp
	daño = s.daño
	defensa = s.defensa
	esquive = s.esquive
	velocidad = s.velocidad
	fe = s.fe
	poder = s.poder
	base_tiempo_ataque = s.base_tiempo_ataque

func _process(delta):
	tiempo_ataque -= delta
	#if cooldown_habilidad > 0:
		#cooldown_habilidad -= delta
	#if habilidad_activa:
		#habilidad_timer -= delta
		#if habilidad_timer <= 0:
			#desactivar_habilidad()
	#if hp > 0 and cooldown_habilidad <= 0:
		#evaluar_activacion_habilidad()



#func evaluar_activacion_habilidad() -> void:
	#pass

func activar_habilidad() -> void:
	habilidad_activa = true
	
func desactivar_habilidad() -> void:
	print("DESACTIVANDO HABILIDAD")
	habilidad_activa = false
	bonus_daño = 1.0
	bonus_defensa = 1.0
	bonus_velocidad = 1.0
	robo_vida = false
	doble_golpe = false
	inmune = false



func puede_atacar() -> bool:
	return tiempo_ataque <= 0 and hp > 0

func reiniciar_tiempo() -> void:
	tiempo_ataque = base_tiempo_ataque / (float(velocidad) * bonus_velocidad)

func recibir_daño(cantidad: int, ignora_bloqueo: bool = false) -> void:
	if hp <= 0 or inmune:
		return
		
	var daño_restante := cantidad
	#BLOQUEO
	if not ignora_bloqueo and bloqueo > 0:
		var absorbido = min(bloqueo, daño_restante)
		bloqueo -= absorbido
		daño_restante -= absorbido
	if daño_restante > 0:
		hp -= daño_restante
		hp = max(hp, 0)
	
	actualizar_barra_vida()
	if hp <= 0:
		morir()

func morir() -> void:
	queue_free()

func actualizar_barra_vida() -> void:
	if !has_node("HealthBar"):
		return
	var barra = $HealthBar
	var porcentaje = float(hp) / float(max_hp) * 100.0
	if vida_tween != null:
		vida_tween.kill()
	vida_tween = create_tween()
	vida_tween.tween_property(barra, "value", porcentaje, 0.2)
	if porcentaje > 50:
		barra.modulate = Color(0.591, 0.809, 0.51)
	elif porcentaje > 10:
		barra.modulate = Color(0.81, 0.692, 0.377)
	else:
		barra.modulate = Color(0.907, 0.337, 0.268)



func aplicar_estado(tipo: TipoEstado, cantidad: int) -> void:
	estados[tipo] = estados.get(tipo, 0) + cantidad

func tiene_estado(tipo: TipoEstado) -> bool:
	return estados.get(tipo, 0) > 0
	
func procesar_estados() -> void:
	if tiene_estado(TipoEstado.SANGRADO):
		var stacks = estados[TipoEstado.SANGRADO]
		recibir_daño(stacks, true)
		estados[TipoEstado.SANGRADO] = max(stacks - 1, 0)

	if tiene_estado(TipoEstado.VENENO):
		var stacks = estados[TipoEstado.VENENO]
		recibir_daño(stacks, false)
		estados[TipoEstado.VENENO] = max(stacks - 1, 0)

	if esquive_buff_turnos > 0:
		esquive_buff_turnos -= 1
		if esquive_buff_turnos <= 0:
			esquive_buff_valor = 0

func esquive_efectivo() -> int:
	return esquive + esquive_buff_valor

func reproducir_animacion(tipo: IntentData.Tipo) -> void:
	# comportamiento genérico por defecto: un tween simple según el tipo
	match tipo:
		IntentData.Tipo.ATACAR:
			_tween_ataque()
		IntentData.Tipo.DEFENDER:
			_tween_defensa()
		IntentData.Tipo.HABILIDAD:
			_tween_habilidad()

func _tween_ataque() -> void:
	var tween = create_tween()
	var pos_original = self.position
	var distancia = 40
	var pos_ataque = pos_original + (Vector2(distancia, 0) if self == Player else Vector2(distancia, 0))
	tween.tween_property(self, "position", pos_ataque, 0.1)
	tween.tween_property(self, "position", pos_original, 0.1)
	

func _tween_defensa() -> void:
	var tween = create_tween()
	var pos_original = self.position
	tween.tween_property(self, "position", pos_original + Vector2(0, -40), 0.1)
	tween.tween_property(self, "position", pos_original, 0.1)

func _tween_habilidad() -> void:
	var tween = create_tween()
	var pos_original = self.position
	tween.tween_property(self, "position", pos_original + Vector2(0, -20), 0.1)
	tween.tween_property(self, "position", pos_original, 0.1)
