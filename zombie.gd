extends CharacterBody3D

var nav_agent 
var player = null

var viteza_patrulare = 2.0
var viteza_urmarire = 5.5
var raza_auz = 15.0

var stare = "PATRULARE"
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	print(">>> 1. SCRIPTUL ZOMBIE A PORNIT! <<<")
	
	
	nav_agent = get_node("NavigationAgent3D")
	
	if nav_agent == null:
		print("!!! EROARE: Nu gasesc NavigationAgent3D!")
		return
		
	cauta_jucatorul()

func cauta_jucatorul():
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
		print("!!! Monstrul nu te gaseste inca...")
		await get_tree().create_timer(1.0).timeout
		cauta_jucatorul()
	else:
		print(">>> 2. Monstrul a vazut Jucatorul. Incepe patrularea!")
		await get_tree().physics_frame
		alege_punct_patrulare()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if player == null or nav_agent == null:
		return

	
	var distanta = global_position.distance_to(player.global_position)
	var jucatorul_se_misca = player.velocity.length() > 0.1
	
	
	if distanta < raza_auz and "este_ascuns" in player and player.este_ascuns == false:
		if jucatorul_se_misca and player.viteza_curenta == player.viteza_mers:
			if stare != "URMARIRE":
				print("--- TE-A AUZIT! FUGI! ---")
				stare = "URMARIRE"
		
	
	if "este_ascuns" in player and player.este_ascuns == true:
		if stare != "PATRULARE":
			print("--- Te-ai ascuns. Monstrul a pierdut urma. ---")
			stare = "PATRULARE"
			alege_punct_patrulare()

	
	if stare == "URMARIRE":
		nav_agent.target_position = player.global_position
	elif stare == "PATRULARE":
		if nav_agent.is_navigation_finished():
			alege_punct_patrulare()

	
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
