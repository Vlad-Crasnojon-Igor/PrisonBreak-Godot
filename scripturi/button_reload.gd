extends Button

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_button_pressed():
	var eroare = get_tree().change_scene_to_file("res://scene/celula.tscn")
	
	if eroare != OK:
		print("Eroare la încărcare! Cod eroare: ", eroare)
