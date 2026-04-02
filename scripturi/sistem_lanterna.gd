extends Node

var baterii_maxime = 5
var baterii_curente = 4 
var timp_per_baterie = 30.0
var energie_activa = 30.0 
var este_aprinsa = false

@onready var lumina = %Felinar
@onready var text_ui = %TextBaterie

func _ready():
	if lumina:
		lumina.hide()
	actualizeaza_ui()

func _process(delta):
	if este_aprinsa:
		energie_activa -= delta 
		
		if energie_activa < 5.0 and energie_activa > 0.0:
			if lumina: lumina.light_energy = randf_range(0.2, 2.0)
		else:
			if lumina: lumina.light_energy = 2.0 
			
		if energie_activa <= 0:
			energie_activa = 0
			consuma_baterie_rezerva()

func consuma_baterie_rezerva():
	if baterii_curente > 0:
		baterii_curente -= 1
		energie_activa = timp_per_baterie
		actualizeaza_ui()
	else:
		stinge_lanterna()

func comuta_lanterna():
	if este_aprinsa:
		stinge_lanterna()
	elif energie_activa > 0 or baterii_curente > 0:
		aprinde_lanterna()
		if energie_activa <= 0 and baterii_curente > 0:
			consuma_baterie_rezerva()

func aprinde_lanterna():
	este_aprinsa = true
	if lumina: lumina.show()

func stinge_lanterna():
	este_aprinsa = false
	if lumina: lumina.hide()

func incarca_bateria() -> bool:
	if baterii_curente < baterii_maxime:
		baterii_curente += 1
		actualizeaza_ui()
		return true 
	return false 

func actualizeaza_ui():
	if text_ui:
		text_ui.text = "Baterii: " + str(baterii_curente) + "/" + str(baterii_maxime)
