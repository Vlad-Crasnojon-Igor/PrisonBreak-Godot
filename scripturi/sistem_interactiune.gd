extends Node

var este_ascuns = false
var dulap_curent = null

var timp_reparatie = 0.0
var este_la_panou = false

@onready var player = get_parent()
@onready var raycast = player.get_node("Camera3D/RayCast3D")
@onready var sistem_inventar = player.get_node("SistemInventar")
@onready var sistem_lanterna = player.get_node("SistemLanterna")
@onready var meniu_seif = player.get_node("CanvasLayer2/MeniuSeif")

func _physics_process(delta):
	if Input.is_action_pressed("interact") and raycast.is_colliding():
		var obiect = raycast.get_collider()
		var quest_ui = get_tree().get_first_node_in_group("InterfataQuest")
		
		# --- HOLD PENTRU PANOU ---
		if obiect.is_in_group("Panou") and quest_ui and quest_ui.componente_gasite >= 3:
			var bara = quest_ui.get_node_or_null("%BaraReparatie")
			if bara:
				timp_reparatie += delta
				bara.show()
				bara.value = (timp_reparatie / 5.0) * 100
				
				if timp_reparatie >= 5.0:
					finalizeaza_reparatia(quest_ui)
					bara.hide() 
					
		# --- HOLD PENTRU MANETE ---
		elif obiect.is_in_group("Maneta") and quest_ui and quest_ui.panou_reparat:
			if not obiect.has_meta("trasa"):
				var bara = quest_ui.get_node_or_null("%BaraReparatie")
				if bara:
					timp_reparatie += delta
					bara.show()
					bara.value = (timp_reparatie / 5.0) * 100
					
					if timp_reparatie >= 5.0:
						obiect.set_meta("trasa", true)
						quest_ui.adauga_maneta() 
						player.afiseaza_mesaj("Manetă de siguranță activată! (" + str(quest_ui.manete_trase) + "/2)")
						reset_reparatie()
		else:
			reset_reparatie()
	else:
		reset_reparatie()

func reset_reparatie():
	timp_reparatie = 0.0
	este_la_panou = false
	
	var quest_ui = get_tree().get_first_node_in_group("InterfataQuest")
	if quest_ui:
		var bara = quest_ui.get_node_or_null("%BaraReparatie")
		if bara:
			bara.hide()
			bara.value = 0

func finalizeaza_reparatia(quest_ui):
	if quest_ui:
		quest_ui.finalizare_reparatie()
	player.afiseaza_mesaj("PANOU REPARAT! UȘA A FOST DEBLOCATĂ")
	reset_reparatie()
	
	if raycast.get_collider():
		raycast.get_collider().remove_from_group("Panou")

func incearca_interactiune():
	var quest_ui = get_tree().get_first_node_in_group("InterfataQuest")

	if este_ascuns == true:
		player.global_position = dulap_curent.get_node("LocExterior").global_position
		este_ascuns = false
		dulap_curent = null
		player.afiseaza_mesaj("Ai iesit din ascunzatoare.")
		return
		
	if raycast.is_colliding():
		var obiect_lovit = raycast.get_collider()
		
		# --- TASK 1: BILETE --- 
		if obiect_lovit.is_in_group("Bilet"):
			sistem_inventar.bucati_cod += 1
			if quest_ui: quest_ui.adauga_bilet()
			if sistem_inventar.bucati_cod == 1:
				player.afiseaza_mesaj("Ai gasit o bucata de hartie: '42..'")
			elif sistem_inventar.bucati_cod == 2:
				player.afiseaza_mesaj("Cod complet: 421. Mergi la Seif!")
			obiect_lovit.queue_free()

		# --- TASK 3: COMPONENTE ---
		elif obiect_lovit.is_in_group("Componenta"):
			if quest_ui:
				quest_ui.adauga_componenta()
				player.afiseaza_mesaj("Ai adunat o componenta electronica.")
				obiect_lovit.queue_free()

		# --- SEIF ---
		elif obiect_lovit.is_in_group("Seif"):
			if sistem_inventar.are_cartela == true:
				player.afiseaza_mesaj("Seiful este gol. Ai luat deja cartela.")
			else:
				meniu_seif.show()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
				
		# --- MESAJE EROARE MANETE (Click scurt) ---
		elif obiect_lovit.is_in_group("Maneta"):
			if quest_ui:
				if not quest_ui.panou_reparat:
					player.afiseaza_mesaj("Nu are curent. Repară panoul electric principal întâi!")
				elif obiect_lovit.has_meta("trasa"):
					player.afiseaza_mesaj("Această manetă este deja activată.")

		# --- USA IESIRE (Actualizata cu Manetele) ---
		elif obiect_lovit.is_in_group("UsaIesire"):
			if quest_ui and quest_ui.panou_reparat:
				if sistem_inventar.are_cartela:
					if quest_ui.manete_trase >= 2:
						player.afiseaza_mesaj("Sistem deblocat. Ai evadat!")
						await get_tree().create_timer(3.0).timeout
						get_tree().quit()
					else:
						player.afiseaza_mesaj("Lockdown activ! Trage cele 2 manete de siguranță.")
				else:
					player.afiseaza_mesaj("Ai nevoie de Cartela Rosie!")
			else:
				player.afiseaza_mesaj("Usa nu are curent. Repara panoul!")
		
		# --- BATERIE ---
		elif obiect_lovit.is_in_group("Baterie"):
				if sistem_lanterna.incarca_bateria():
					obiect_lovit.get_parent().queue_free()
					player.afiseaza_mesaj("Ai gasit o baterie!")
					
		# --- ASCUNZATOARE ---
		elif obiect_lovit.is_in_group("Ascunzatoare"):
			dulap_curent = obiect_lovit.get_parent() 
			player.global_position = dulap_curent.get_node("LocInterior").global_position 
			este_ascuns = true
			player.afiseaza_mesaj("Te-ai ascuns! Apasa E ca sa iesi.")
