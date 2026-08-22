@tool
extends Control

@onready var selector: OptionButton = $MarginContainer/VBoxContainer/OptionButton
@onready var spin_ancho: SpinBox = $MarginContainer/VBoxContainer/HBoxContainerAncho/SpinBox
@onready var spin_alto: SpinBox = $MarginContainer/VBoxContainer/HBoxContainerAlto/SpinBox
@onready var boton_ejecutar: Button = $MarginContainer/VBoxContainer/Button

const DEFAULT_ANCHO := 1280
const DEFAULT_ALTO := 720

var resoluciones := [
	Vector2i(DEFAULT_ANCHO, DEFAULT_ALTO),
	Vector2i(1024,768),
	Vector2i(1152,864),
	Vector2i(1366,768),
	Vector2i(1440,900),
	Vector2i(1600,900),
	Vector2i(1920,1080),
	Vector2i(2560,1440),
	Vector2i(3840,2160)
]


func _ready() -> void:
	_configurar_selector()

func _configurar_selector() -> void:
	selector.clear()
	
	for resolucion in resoluciones:
		selector.add_item("%d x %d" % [resolucion.x, resolucion.y])
		
	selector.select(0)
	
	spin_ancho.value = DEFAULT_ANCHO
	spin_alto.value = DEFAULT_ALTO
	
	selector.item_selected.connect(_on_resolucion_seleccionada)
	boton_ejecutar.pressed.connect(_on_ejecutar_pressed)

func _on_resolucion_seleccionada(indice: int) -> void: 
	var resolucion: Vector2i = resoluciones[indice]
	
	spin_ancho.value = resolucion.x
	spin_alto.value = resolucion.y
	
func _on_ejecutar_pressed() -> void: 
	var ancho := int(spin_ancho.value)
	var alto := int(spin_alto.value)
	
	var resolucion := "%dx%d" % [ancho, alto]
	
	print("Ejecutando juego en: ", resolucion)
	
	var argumentos := [
		"--path",
		ProjectSettings.globalize_path("res://"),
		"--resolution",
		resolucion
	]
	
	OS.create_process(
		OS.get_executable_path(),
		argumentos
	)
	
	
