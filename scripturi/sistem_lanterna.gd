extends Node

var baterie_curenta = 3
var baterie_maxima = 5
var durata_baterie = 30.0 
var timer_baterie = durata_baterie

@onready var felinar = $"../Camera3D/Felinar" 
@onready var baterie_ui = $"../CanvasLayer2/BaterieUI"
@onready var player = get_parent() 

func _ready():
	actualizeaza_ui()
	
func _process(delta):
	if felinar == null: return 
	
	if baterie_curenta > 0 and felinar.visible:
		timer_baterie -= delta 
		if timer_baterie <= 0:
			baterie_curenta -= 1 
			timer_baterie = durata_baterie 
			actualizeaza_ui()
			
			if baterie_curenta <= 0: 
				felinar.visible = false 

func comuta_lanterna():
	if felinar == null: return
	if baterie_curenta > 0:
		felinar.visible = !felinar.visible 
	else:
		player.afiseaza_mesaj("Fara baterie!")

func actualizeaza_ui():
	if baterie_ui:
		baterie_ui.text = "Baterie: " + str(baterie_curenta) + "/" + str(baterie_maxima)

func incarca_bateria() -> bool:
	if baterie_curenta < baterie_maxima:
		baterie_curenta += 1
		actualizeaza_ui()
		return true
	else:
		return false
