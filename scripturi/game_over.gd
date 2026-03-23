extends Control

@onready var sunet = $SunetMoarte 

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if sunet:
		sunet.play() 
	else:
		print("Eroare: Nu am găsit nodul audio!")

func _process(delta: float) -> void:
	pass
