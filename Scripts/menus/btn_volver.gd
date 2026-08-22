extends Button

@onready var hover_sound = $HoverSound

func _ready():
	mouse_entered.connect(_on_mouse_entered)

func _on_mouse_entered():
	if hover_sound:
		hover_sound.play()
