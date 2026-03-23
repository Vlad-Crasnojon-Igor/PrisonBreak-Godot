extends CharacterBody3D

@onready var sunet_patrulare = $SunetPatrulare
@onready var sunet_alerta = $SunetAlerta

var nav_agent 
var player = null

var viteza_patrulare = 2.0
var viteza_urmarire = 5.0 # <-- Reparat (pus .0 ca să fie compatibil)
var raza_auz = 15.0

var stare = "PATRULARE" # Acum avem 3 stări: PATRULARE, ALERTA, URMARIRE
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	print(">>> SCRIPTUL ZOMBIE A PORNIT <<<")
	nav_agent = get_node("NavigationAgent3D")
	cauta_jucatorul()

func cauta_jucatorul():
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
		await get_tree().create_timer(1.0).timeout
		cauta_jucatorul()
	else:
		if not sunet_patrulare.playing:
			sunet_patrulare.play()
		await get_tree().physics_frame
		alege_punct_patrulare()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if player == null or nav_agent == null:
		return

	var distanta = global_position.distance_to(player.global_position)
	var jucatorul_se_misca = player.velocity.length() > 0.1
	
	if distanta < 1:
		print("TE-A PRINS! GAME OVER!")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file.call_deferred("res://scene/game_over.tscn") # Ai grija sa fie calea corecta aici!
		return 

	var player_ascuns = false
	if "sistem_interactiune" in player and player.sistem_interactiune != null:
		player_ascuns = player.sistem_interactiune.este_ascuns

	# --- VERIFICĂM DACĂ TE AUDE (Trece în starea de ALERTA) ---
	if distanta < raza_auz and not player_ascuns:
		if jucatorul_se_misca and player.viteza_curenta == player.viteza_mers:
			# Doar dacă e liniștit poate fi alertat (previne repetarea la infinit)
			if stare == "PATRULARE": 
				stare = "ALERTA"
				print("--- TE-A AUZIT! ZOMBIE-UL SE OPRESTE SA URLE! ---")
				
				# Schimbăm sunetele
				if sunet_patrulare.playing:
					sunet_patrulare.stop()
				if not sunet_alerta.playing:
					sunet_alerta.play()
					
				# Oprim monstrul pe loc
				velocity.x = 0
				velocity.z = 0
				
				# Așteptăm 1.5 secunde (pauza de teroare)
				await get_tree().create_timer(1.5).timeout
				
				# Dacă în astea 1.5 secunde nu te-ai ascuns în dulap, începe alergarea!
				if stare == "ALERTA":
					stare = "URMARIRE"
		
	# --- VERIFICĂM DACĂ TE-AI ASCUNS ---
	if player_ascuns:
		if stare != "PATRULARE":
			print("--- Te-ai ascuns. Monstrul a pierdut urma. ---")
			stare = "PATRULARE"
			alege_punct_patrulare()
			
			if sunet_alerta.playing:
				sunet_alerta.stop()
			if not sunet_patrulare.playing:
				sunet_patrulare.play()

	# --- SETAREA DESTINATIEI ---
	if stare == "URMARIRE":
		nav_agent.target_position = player.global_position
	elif stare == "PATRULARE":
		if nav_agent.is_navigation_finished():
			alege_punct_patrulare()

	# --- MISCAREA (Se misca DOAR daca NU e in Alerta) ---
	if stare != "ALERTA":
		if not nav_agent.is_navigation_finished():
			var urmatorul_punct = nav_agent.get_next_path_position()
			var directie = global_position.direction_to(urmatorul_punct)
			directie.y = 0 
			directie = directie.normalized()
			
			var v_cur = viteza_urmarire if stare == "URMARIRE" else viteza_patrulare
			velocity.x = directie.x * v_cur
			velocity.z = directie.z * v_cur
			
			if directie != Vector3.ZERO:
				var look_target = global_position + directie
				if global_position.distance_to(look_target) > 0.1:
					look_at(look_target, Vector3.UP)
		else:
			velocity.x = move_toward(velocity.x, 0, viteza_patrulare)
			velocity.z = move_toward(velocity.z, 0, viteza_patrulare)

	move_and_slide()

func alege_punct_patrulare():
	var offset_random = Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
	nav_agent.target_position = global_position + offset_random
