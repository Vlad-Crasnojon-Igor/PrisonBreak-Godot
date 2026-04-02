extends CanvasLayer

@onready var task1 = $MarginContainer/VBoxContainer/Task1
@onready var task2 = $MarginContainer/VBoxContainer/Task2
@onready var task3 = $MarginContainer/VBoxContainer/Task3
@onready var task4 = $MarginContainer/VBoxContainer/Task4
@onready var task5 = $MarginContainer/VBoxContainer/Task5
@onready var task6 = $MarginContainer/VBoxContainer/Task6 # Adăugăm referința pentru quest-ul 6

var bilete_gasite = 0
var seif_deschis = false
var componente_gasite = 0
var panou_reparat = false
var manete_trase = 0

func _ready():
	actualizeaza_ui()

func actualizeaza_ui():
	# TASK 1
	if bilete_gasite < 2:
		task1.text = "1. Găsește notițele cu parola (" + str(bilete_gasite) + "/2)"
	else:
		task1.text = "1. Găsește notițele cu parola (2/2) - COMPLET"
		task1.add_theme_color_override("font_color", Color.GREEN)

	# TASK 2
	if not seif_deschis:
		task2.text = "2. Obține Cartela Roșie din seif"
	else:
		task2.text = "2. Obține Cartela Roșie din seif - COMPLET"
		task2.add_theme_color_override("font_color", Color.GREEN)

	# TASK 3
	if componente_gasite < 3:
		task3.text = "3. Găsește siguranțele electronice (" + str(componente_gasite) + "/3)"
	else:
		task3.text = "3. Găsește siguranțele electronice (3/3) - COMPLET"
		task3.add_theme_color_override("font_color", Color.GREEN)

	# TASK 4
	if not panou_reparat:
		task4.text = "4. Repară panoul electric"
	else:
		task4.text = "4. Repară panoul electric - COMPLET"
		task4.add_theme_color_override("font_color", Color.GREEN)

	# TASK 5 (Manetele)
	if manete_trase < 2:
		task5.text = "5. Trage manetele de siguranță (" + str(manete_trase) + "/2)"
	else:
		task5.text = "5. Trage manetele de siguranță (2/2) - COMPLET"
		task5.add_theme_color_override("font_color", Color.GREEN)

	# TASK 6 (Evadarea)
	if seif_deschis and panou_reparat and manete_trase >= 2:
		task6.text = "6. Evadează prin ușa principală! (DESCHISĂ)"
		task6.add_theme_color_override("font_color", Color.GREEN)
	else:
		task6.text = "6. Evadează prin ușa principală (BLOCATĂ)"

# --- FUNCȚII DE ACTUALIZARE ---

func adauga_bilet():
	if bilete_gasite < 2:
		bilete_gasite += 1
		actualizeaza_ui()

func deschide_seif():
	seif_deschis = true
	actualizeaza_ui()

func adauga_componenta():
	if componente_gasite < 3:
		componente_gasite += 1
		actualizeaza_ui()

func finalizare_reparatie():
	panou_reparat = true
	actualizeaza_ui()

# Funcția nouă pentru apelul din sistemul de interacțiune
func adauga_maneta():
	if manete_trase < 2:
		manete_trase += 1
		actualizeaza_ui()
