extends Node

var este_ascuns = false
var dulap_curent = null

@onready var player = get_parent()
@onready var raycast = player.get_node("Camera3D/RayCast3D")
@onready var sistem_inventar = player.get_node("SistemInventar")
@onready var sistem_lanterna = player.get_node("SistemLanterna")
@onready var meniu_seif = player.get_node("CanvasLayer2/MeniuSeif")

func incearca_interactiune():
	if este_ascuns == true:
		player.global_position = dulap_curent.get_node("LocExterior").global_position
		este_ascuns = false
		dulap_curent = null
		player.afiseaza_mesaj("Ai iesit din ascunzatoare.")
		return
		
	if raycast.is_colliding():
		var obiect_lovit = raycast.get_collider()
		
		if obiect_lovit.is_in_group("Bilet"):
			sistem_inventar.bucati_cod += 1
			obiect_lovit.queue_free()
			if sistem_inventar.bucati_cod == 1:
				player.afiseaza_mesaj("Ai gasit o bucata de hartie rupta: '45..'")
			elif sistem_inventar.bucati_cod == 2:
				player.afiseaza_mesaj("Ai gasit a doua bucata! Codul complet: 4582")
			
		elif obiect_lovit.is_in_group("Usa"):
			if sistem_inventar.bucati_cod == 2:
				player.afiseaza_mesaj("Ai descuiat usa celulei...")
				var harta_aleasa = sistem_inventar.lista_harti.pick_random()
				get_tree().call_deferred("change_scene_to_file", harta_aleasa)
			else:
				player.afiseaza_mesaj("Usa celulei e blocata. Mai cauta...")
				
		elif obiect_lovit.is_in_group("Seif"):
			if sistem_inventar.are_cartela == true:
				player.afiseaza_mesaj("Seiful este gol. Ai luat deja cartela.")
			else:
				meniu_seif.show()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
				
		elif obiect_lovit.is_in_group("UsaIesire"):
			if sistem_inventar.are_cartela == true:
				player.afiseaza_mesaj("Ai scanat Cartela Rosie. Usa se deschide...")
				await get_tree().create_timer(3.0).timeout
				get_tree().quit() 
			else:
				player.afiseaza_mesaj("Acces Respins. Ai nevoie de o Cartela Rosie.")
				
		elif obiect_lovit.is_in_group("Baterie"):
			if sistem_lanterna.incarca_bateria():
				obiect_lovit.get_parent().queue_free() 
				player.afiseaza_mesaj("Ai gasit o baterie!")
			else:
				player.afiseaza_mesaj("Felinarul este deja incarcat la maxim.")
			
		elif obiect_lovit.is_in_group("Ascunzatoare"):
			dulap_curent = obiect_lovit.get_parent() 
			player.global_position = dulap_curent.get_node("LocInterior").global_position 
			este_ascuns = true
			player.afiseaza_mesaj("Te-ai ascuns! Apasa E ca sa iesi.")
