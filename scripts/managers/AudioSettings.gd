extends Node

const SETTINGS_PATH := "user://settings.dat"

var music := 100.0
var sfx := 100.0
var voces := 100.0

func _ready():
	cargar()
	aplicar()

func aplicar():
	set_bus_volume("Music", music)
	set_bus_volume("SFX", sfx)
	set_bus_volume("Voces", voces)

func set_bus_volume(bus_name: String, value: float):
	var bus := AudioServer.get_bus_index(bus_name)
	if bus == -1:
		push_warning("Bus no encontrado: " + bus_name)
		return

	AudioServer.set_bus_volume_db(
		bus,
		linear_to_db(value / 100.0)
	)

func guardar():
	var data := {
		"music": music,
		"sfx": sfx,
		"voces": voces
	}

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func cargar():
	if not FileAccess.file_exists(SETTINGS_PATH):
		return

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	var data: Dictionary = file.get_var()
	file.close()

	music = data.get("music", 100.0)
	sfx = data.get("sfx", 100.0)
	voces = data.get("voces", 100.0)
