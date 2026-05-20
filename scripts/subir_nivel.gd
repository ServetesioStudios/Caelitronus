extends Control


@onready var hover_sound = $HoverSound
var incrementoira = [10,2,1,1,2,1,2]
var incrementoego = [9,1,2,1,2,3,1]
var incrementopena = [8,1,1,2,2,3,2]
var aumento1 = [0,0,0,0,0,0,0]
var aumento2 = [0,0,0,0,0,0,0]
var aumento3 = [0,0,0,0,0,0,0]
var stats = []
var final = []
var tipo = ""
var nivel = 0
var progreso = ConfigFile.new()
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	$Botones/Confirmar.set_block_signals(1)
	$Botones/Confirmar.disabled = true
	
	var err = progreso.load("res://cfg/progreso.cfg")
	if err == OK:
		nivel = progreso.get_value("Caelius","nivel")
		stats = progreso.get_value("Caelius","stats")
		$Nivelanterior/Label.text += str(nivel)
		$Nivelactual/Label.text += str(nivel+1)
		$Nivelanterior/Vida.text += str(stats[0])
		$Nivelanterior/Ataque.text += str(stats[1])
		$Nivelanterior/Defensa.text += str(stats[2])
		$Nivelanterior/Esquive.text += str(stats[3])
		$Nivelanterior/Velocidad.text += str(stats[4]/10.0)
		$Nivelanterior/Fe.text += str(stats[5])
		$Nivelanterior/Poder.text += str(stats[6])
		tipo = progreso.get_value("Caelius","tipo")
		match tipo:
			"ira":
				cargar(incrementoira,stats,aumento1)
			"ego":
				cargar(incrementoego,stats,aumento1)
			"pena":
				cargar(incrementopena,stats,aumento1)
				
	$Botones/Opcion1/Texto.text = randomincremento(1)
	$Botones/Opcion2/Texto.text = randomincremento(2)
	while $Botones/Opcion1/Texto.text == $Botones/Opcion2/Texto.text:
		aumento2 = [0,0,0,0,0,0,0]
		$Botones/Opcion2/Texto.text = randomincremento(2)
	$Botones/Opcion3/Texto.text = randomincremento(3)
	while $Botones/Opcion1/Texto.text == $Botones/Opcion3/Texto.text or $Botones/Opcion2/Texto.text == $Botones/Opcion3/Texto.text:
		aumento3 = [0,0,0,0,0,0,0]
		$Botones/Opcion3/Texto.text = randomincremento(3)


func cargar(incremento,s,a):
	final=[]
	for i in range(s.size()):
		final.append(incremento[i]+s[i]+a[i])
	
	var iconos = "[img=30]assets/Icons/der.png[/img] [img=30]assets/Icons/der.png[/img]"
	if a[0] == 0:
		$Aumento/Vida.text = iconos+" "+str(incremento[0])+" "+iconos
		$Nivelactual/Vida.text = "[img=40 color=black]assets/Icons/vida.png[/img] "+str(incremento[0]+s[0])
	else:
		$Aumento/Vida.text = iconos+" "+"[color=green]"+str(incremento[0]+a[0])+"[/color] "+iconos
		$Nivelactual/Vida.text = "[img=40 color=black]assets/Icons/vida.png[/img] "+"[color=green]"+str(incremento[0]+s[0]+a[0])
	if a[1] == 0:
		$Aumento/Ataque.text = iconos+" "+str(incremento[1])+" "+iconos
		$Nivelactual/Ataque.text = "[img=40 color=black]assets/Icons/Espada.png[/img] "+str(incremento[1]+s[1])
	else:
		$Aumento/Ataque.text = iconos+" "+"[color=green]"+str(incremento[1]+a[1])+"[/color] "+iconos
		$Nivelactual/Ataque.text = "[img=40 color=black]assets/Icons/Espada.png[/img] "+"[color=green]"+str(incremento[1]+s[1]+a[1])
	if a[2] == 0:	 
		$Aumento/Defensa.text = iconos+" "+str(incremento[2])+" "+iconos
		$Nivelactual/Defensa.text = "[img=40 color=black]assets/Icons/Escudo.png[/img] "+str(incremento[2]+s[2])
	else:
		$Aumento/Defensa.text = iconos+" "+"[color=green]"+str(incremento[2]+a[2])+"[/color] "+iconos
		$Nivelactual/Defensa.text = "[img=40 color=black]assets/Icons/Escudo.png[/img] "+"[color=green]"+str(incremento[2]+s[2]+a[2])
	if a[3] == 0: 
		$Aumento/Esquive.text = iconos+" "+str(incremento[3])+" "+iconos
		$Nivelactual/Esquive.text = "[img=40 color=black]assets/Icons/esquive.png[/img] "+str(incremento[3]+s[3])
	else:
		$Aumento/Esquive.text = iconos+" "+"[color=green]"+str(incremento[3]+a[3])+"[/color] "+iconos
		$Nivelactual/Esquive.text = "[img=40 color=black]assets/Icons/esquive.png[/img] "+"[color=green]"+str(incremento[3]+s[3]+a[3])
	if a[4] == 0:  
		$Aumento/Velocidad.text = iconos+" "+str(incremento[4]/10.0)+" "+iconos
		$Nivelactual/Velocidad.text = "[img=40 color=black]assets/Icons/Velocidad.png[/img] "+str((incremento[4]+s[4])/10.0)
	else:
		$Aumento/Velocidad.text = iconos+" "+"[color=green]"+str((incremento[4]+a[4])/10.0)+"[/color] "+iconos
		$Nivelactual/Velocidad.text = "[img=40 color=black]assets/Icons/Velocidad.png[/img] "+"[color=green]"+str((incremento[4]+s[4]+a[4])/10.0)
	if a[5] == 0:  
		$Aumento/Fe.text = iconos+" "+str(incremento[5])+" "+iconos
		$Nivelactual/Fe.text = "[img=40 color=black]assets/Icons/fe.png[/img] "+str(incremento[5]+s[5])
	else:
		$Aumento/Fe.text = iconos+" "+"[color=green]"+str(incremento[5]+a[5])+"[/color] "+iconos
		$Nivelactual/Fe.text = "[img=40 color=black]assets/Icons/fe.png[/img] "+"[color=green]"+str(incremento[5]+s[5]+a[5])
	if a[6] == 0: 
		$Aumento/Poder.text = iconos+" "+str(incremento[6])+" "+iconos
		$Nivelactual/Poder.text = "[img=40 color=black]assets/Icons/poder.png[/img] "+str(incremento[6]+s[6])
	else:
		$Aumento/Poder.text = iconos+" "+"[color=green]"+str(incremento[6]+a[6])+"[/color] "+iconos
		$Nivelactual/Poder.text = "[img=40 color=black]assets/Icons/poder.png[/img] "+"[color=green]"+str(incremento[6]+s[6]+a[6])


func _on_button_mouse_entered() -> void:
	if hover_sound.playing == true:
		hover_sound.stop()
	hover_sound.play()


func randomincremento(opc):
	var texto = ""
	var random1 = rng.randi_range(0, 6)
	var random2 = rng.randi_range(0, 6)
	while random1 == random2:
		random2 = rng.randi_range(0, 6)
	texto = opcionesTexto(random1,opc)
	texto += "  " + opcionesTexto(random2,opc)
	return texto

func opcionesTexto(r,opc):
	var texto = ""
	var cantidad = 5
	match r:
		0:
			cantidad = 25
			texto = "[img=40 color=black]assets/Icons/vida.png[/img] " + str(cantidad)
		1:
			texto = "[img=40 color=black]assets/Icons/Espada.png[/img] " + str(cantidad)
		2:
			texto = "[img=40 color=black]assets/Icons/Escudo.png[/img] " + str(cantidad)
		3:
			texto = "[img=40 color=black]assets/Icons/esquive.png[/img] " + str(cantidad)
		4:
			texto = "[img=40 color=black]assets/Icons/Velocidad.png[/img] " + str(cantidad/10.0)
		5:
			texto = "[img=40 color=black]assets/Icons/fe.png[/img] " + str(cantidad)
		6:
			texto = "[img=40 color=black]assets/Icons/poder.png[/img] " + str(cantidad)
	match opc:
		1:
			aumento1[r] = cantidad
		2:
			aumento2[r] = cantidad
		3:
			aumento3[r] = cantidad
	return texto


func _on_opcion_1_pressed() -> void:
	seleccionarOpcion(1)
	
func _on_opcion_2_pressed() -> void:
	seleccionarOpcion(2)

func _on_opcion_3_pressed() -> void:
	seleccionarOpcion(3)
	
func seleccionarOpcion(opc):
	$Botones/Opcion1.remove_theme_stylebox_override("normal")
	$Botones/Opcion2.remove_theme_stylebox_override("normal")
	$Botones/Opcion3.remove_theme_stylebox_override("normal")
	var aumento
	match opc:
		1:
			$Botones/Opcion1.add_theme_stylebox_override("normal",$Botones/Opcion1.get_theme_stylebox("hover"))
			aumento = aumento1
		2:
			$Botones/Opcion2.add_theme_stylebox_override("normal",$Botones/Opcion2.get_theme_stylebox("hover"))
			aumento = aumento2
		3:
			$Botones/Opcion3.add_theme_stylebox_override("normal",$Botones/Opcion3.get_theme_stylebox("hover"))
			aumento = aumento3
	match tipo:
			"ira":
				cargar(incrementoira,stats,aumento)
			"ego":
				cargar(incrementoego,stats,aumento)
			"pena":
				cargar(incrementopena,stats,aumento)
	$Botones/Confirmar.set_block_signals(0)
	$Botones/Confirmar.disabled = false

func _on_confirmar_pressed() -> void:
	progreso.set_value("Caelius","nivel",nivel+1)
	progreso.set_value("Caelius","stats",final)
	progreso.save("res://cfg/progreso.cfg")
	get_tree().change_scene_to_file("res://scenes/battelscena.tscn")
	

func _process(_delta):
	if $Tooltip.visible == true:
		$Tooltip.global_position = get_global_mouse_position() + Vector2(10,-40)

func mostrarOcultar():
	if $Tooltip.visible == true:
		$Tooltip.hide()
	else:
		$Tooltip.show()

func _on_vida_mouse_entered() -> void:
	$Tooltip/Texto.text = "[b]Vida[/b]\nCantidad de daño maximo que puedes recibir"
	mostrarOcultar()

func _on_ataque_mouse_entered() -> void:
	$Tooltip/Texto.text = "[b]Ataque(ATQ)[/b]\nDaño que recibe el enemigo (variable de 85% a 105% menos [b]Defensa[/b] del enemigo)"
	mostrarOcultar()

func _on_defensa_mouse_entered() -> void:
	$Tooltip/Texto.text = "[b]Defensa(DEF)[/b]\nReduce el daño recibido por [b]Ataque[/b]"
	mostrarOcultar()

func _on_esquive_mouse_entered() -> void:
	$Tooltip/Texto.text = "[b]Esquive(ESQ)[/b]\nChance de evitar totalmente el [b]Ataque[/b] enemigo"
	mostrarOcultar()

func _on_velocidad_mouse_entered() -> void:
	$Tooltip/Texto.text = "[b]Velocidad(VEL)[/b]\nMultiplica la cantidad de ataques o habilidades que puedes realizar por turno"
	mostrarOcultar()

func _on_fe_mouse_entered() -> void:
	$Tooltip/Texto.text = "[b]Fe[/b]\nReduce el enfriamiento de tus habilidades (0.08 por punto, maxima reduccion en 100 de [b]Fe[/b])"
	mostrarOcultar()

func _on_poder_mouse_entered() -> void:
	$Tooltip/Texto.text = "[b]Poder[/b]\nChance de realizar un [b]Ataque[/b] critico"
	mostrarOcultar()

func _on_mouse_exited() -> void:
	mostrarOcultar()
