extends Light3D

@export_group("Setari Lumina")
@export var energie_normala: float = 0.8
@export var energie_minima: float = 0.1

@export_group("Setari Timp (Secunde)")
@export var pauza_minima: float = 2.0  # Timpul minim în care lumina merge normal
@export var pauza_maxima: float = 8.0  # Timpul maxim în care lumina merge normal
@export var durata_palpaire_min: float = 0.2
@export var durata_palpaire_max: float = 1.5

var se_strica: bool = false
var timer_stare: float = 0.0
var timp_urmatoarea_schimbare: float = 0.0

func _ready():
	# Ne asigurăm că fiecare bec din joc pâlpâie diferit, nu toate deodată
	randomize()
	light_energy = energie_normala
	seteaza_urmatorul_interval(false)

func _process(delta):
	timer_stare += delta
	
	if not se_strica:
		# Starea normală: becul e aprins constant
		if timer_stare >= timp_urmatoarea_schimbare:
			se_strica = true
			seteaza_urmatorul_interval(true)
	else:
		# Starea de defecțiune: becul pâlpâie
		if timer_stare >= timp_urmatoarea_schimbare:
			se_strica = false
			light_energy = energie_normala
			seteaza_urmatorul_interval(false)
		else:
			# Efectul efectiv de pâlpâire (șansă de 50% pe cadru să scadă lumina)
			if randf() > 0.5:
				light_energy = randf_range(energie_minima, energie_normala - 0.2)
			else:
				light_energy = energie_normala

func seteaza_urmatorul_interval(pentru_palpaire: bool):
	timer_stare = 0.0
	if pentru_palpaire:
		timp_urmatoarea_schimbare = randf_range(durata_palpaire_min, durata_palpaire_max)
	else:
		timp_urmatoarea_schimbare = randf_range(pauza_minima, pauza_maxima)
