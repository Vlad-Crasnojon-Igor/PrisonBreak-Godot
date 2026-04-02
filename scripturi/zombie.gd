extends CharacterBody3D

@onready var sunet_patrulare = $SunetPatrulare
@onready var sunet_alerta = $SunetAlerta
@onready var anim_player = $"Zombie Scream/AnimationPlayer"

var nav_agent 
var player = null

var viteza_patrulare = 2.0
var viteza_urmarire = 5.0 
var raza_auz = 13.0

var stare = "PATRULARE" 
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	nav_agent = get_node("NavigationAgent3D")
	
	if anim_player:
		anim_player.play("mutant_walk")
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
	
	if distanta < 1.8:
		print("GAME OVER!")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file.call_deferred("res://scene/game_over.tscn")
		return 

	var player_ascuns = false
	if "sistem_interactiune" in player and player.sistem_interactiune != null:
		player_ascuns = player.sistem_interactiune.este_ascuns

	
	if distanta < raza_auz and not player_ascuns:
		if jucatorul_se_misca and player.viteza_curenta == player.viteza_mers:
			if stare == "PATRULARE": 
				stare = "ALERTA"
				print("TE-A AUZIT")
				
			
				if anim_player:
					anim_player.play("mutant_scream")
				
				
				if sunet_patrulare.playing:
					sunet_patrulare.stop()
				if not sunet_alerta.playing:
					sunet_alerta.play()
					
				velocity.x = 0
				velocity.z = 0
				await get_tree().create_timer(1.5).timeout
				
				if stare == "ALERTA":
					stare = "URMARIRE"
					
					if anim_player:
						anim_player.play("mutant_run")
		
	if player_ascuns:
		if stare != "PATRULARE":
			print(" Te-ai ascuns")
			stare = "PATRULARE"
			alege_punct_patrulare()
			
			if anim_player:
				anim_player.play("mutant_walk")
			
			if sunet_alerta.playing:
				sunet_alerta.stop()
			if not sunet_patrulare.playing:
				sunet_patrulare.play()

	if stare == "URMARIRE":
		nav_agent.target_position = player.global_position
	elif stare == "PATRULARE":
		if nav_agent.is_navigation_finished():
			alege_punct_patrulare()

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
				var target_rotation = atan2(directie.x, directie.z)
				rotation.y = lerp_angle(rotation.y, target_rotation, delta * 10.0)
		else:
			velocity.x = move_toward(velocity.x, 0, viteza_patrulare)
			velocity.z = move_toward(velocity.z, 0, viteza_patrulare)
			
			if stare == "PATRULARE" and anim_player != null:
				if anim_player.current_animation == "mutant_walk":
					anim_player.seek(0.0, true)

	move_and_slide()

func alege_punct_patrulare():
	var offset_random = Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
	nav_agent.target_position = global_position + offset_random
