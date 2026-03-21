extends CharacterBody3D

var viteza_mers = 5.0
var viteza_crouch = 2.0
var viteza_curenta = 5.0 
const JUMP_VELOCITY = 4.5

var interval_pasi = 0.5
var timer_pasi = 0.0

var bucati_cod = 0
var are_cartela = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = 0.002 

var baterie_curenta = 3
var baterie_maxima = 5
var durata_baterie = 30.0 
var timer_baterie = durata_baterie

var este_ascuns = false
var dulap_curent = null

@onready var sunet_pasi = $SunetPasi
@onready var felinar = $Camera3D/Felinar
@onready var baterie_ui = $CanvasLayer2/BaterieUI
@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var mesaj_ui = $CanvasLayer2/MesajUI
@onready var hitbox = $CollisionShape3D 
@onready var meniu_seif = $CanvasLayer2/MeniuSeif
@onready var input_cod = $CanvasLayer2/MeniuSeif/InputCod

var lista_harti = [
	"res://game.tscn"
]

func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mesaj_ui.hide()
	meniu_seif.hide()
	baterie_ui.text = "Baterie: " + str(baterie_curenta) + "/" + str(baterie_maxima)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			meniu_seif.hide()

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	if Input.is_action_just_pressed("toggle_flashlight"):
		if baterie_curenta > 0:
			felinar.visible = !felinar.visible 
		else:
			afiseaza_mesaj("Nu ai baterie pentru a aprinde felinarul!")
			
	if baterie_curenta > 0 and felinar.visible == true:
		timer_baterie -= delta 
		
		if timer_baterie <= 0:
			baterie_curenta -= 1 
			timer_baterie = durata_baterie 
			baterie_ui.text = "Baterie: " + str(baterie_curenta) + "/" + str(baterie_maxima)
			
			if baterie_curenta == 1:
				afiseaza_mesaj("Atentie: Bateria felinarului este pe terminate!")
			elif baterie_curenta <= 0:
				felinar.visible = false 
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("move_left", "move_right", "move_foward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if este_ascuns == false:
		if Input.is_action_pressed("move_crouch"):
			viteza_curenta = viteza_crouch
			hitbox.shape.height = move_toward(hitbox.shape.height, 1.0, delta * 4.0)
			camera.position.y = move_toward(camera.position.y, 0.0, delta * 4.0)
		else:
			viteza_curenta = viteza_mers
			hitbox.shape.height = move_toward(hitbox.shape.height, 2.0, delta * 4.0)
			camera.position.y = move_toward(camera.position.y, 0.5, delta * 4.0)

		if Input.is_action_just_pressed("move_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if direction:
			velocity.x = direction.x * viteza_curenta
			velocity.z = direction.z * viteza_curenta
		else:
			velocity.x = move_toward(velocity.x, 0, viteza_curenta)
			velocity.z = move_toward(velocity.z, 0, viteza_curenta)
	else:
		velocity.x = 0
		velocity.z = 0

	if direction and is_on_floor() and viteza_curenta == viteza_mers and este_ascuns == false:
		timer_pasi -= delta 
		
		if timer_pasi <= 0:
			sunet_pasi.play() 
			timer_pasi = interval_pasi 
	else:
		timer_pasi = 0.0
		
	if Input.is_action_just_pressed("interact"):
		if este_ascuns == true:
			global_position = dulap_curent.get_node("LocExterior").global_position
			este_ascuns = false
			dulap_curent = null
			afiseaza_mesaj("Ai iesit din ascunzatoare.")
			
		elif raycast.is_colliding():
			var obiect_lovit = raycast.get_collider()
			
			if obiect_lovit.is_in_group("Bilet"):
				bucati_cod += 1
				obiect_lovit.queue_free()
				if bucati_cod == 1:
					afiseaza_mesaj("Ai gasit o bucata de hartie rupta: '45..'")
				elif bucati_cod == 2:
					afiseaza_mesaj("Ai gasit a doua bucata! Codul complet: 4582")
				
			elif obiect_lovit.is_in_group("Usa"):
				if bucati_cod == 2:
					afiseaza_mesaj("Ai descuiat usa celulei...")
					var harta_aleasa = lista_harti.pick_random()
					get_tree().call_deferred("change_scene_to_file", harta_aleasa)
				else:
					afiseaza_mesaj("Usa celulei e blocata. Mai cauta...")
					
			elif obiect_lovit.is_in_group("Seif"):
				if are_cartela == true:
					afiseaza_mesaj("Seiful este gol. Ai luat deja cartela.")
				else:
					meniu_seif.show()
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
					
			elif obiect_lovit.is_in_group("UsaIesire"):
				if are_cartela == true:
					afiseaza_mesaj("Ai scanat Cartela Rosie. Usa se deschide...")
					await get_tree().create_timer(3.0).timeout
					get_tree().quit() 
				else:
					afiseaza_mesaj("Acces Respins. Ai nevoie de o Cartela Rosie.")
					
			elif obiect_lovit.is_in_group("Baterie"):
				if baterie_curenta < baterie_maxima:
					baterie_curenta += 1
					baterie_ui.text = "Baterie: " + str(baterie_curenta) + "/" + str(baterie_maxima)
					obiect_lovit.get_parent().queue_free() 
					afiseaza_mesaj("Ai gasit o baterie!")
				else:
					afiseaza_mesaj("Felinarul este deja incarcat la maxim.")
					
			elif obiect_lovit.is_in_group("Ascunzatoare"):
				dulap_curent = obiect_lovit.get_parent() 
				global_position = dulap_curent.get_node("LocInterior").global_position 
				este_ascuns = true
				afiseaza_mesaj("Te-ai ascuns! Apasa E ca sa iesi.")

	move_and_slide()

func afiseaza_mesaj(text_nou):
	mesaj_ui.text = text_nou
	mesaj_ui.show()
	await get_tree().create_timer(3.0).timeout
	mesaj_ui.hide()

func _on_button_open_pressed():
	if input_cod.text == "421":
		afiseaza_mesaj("Cod Corect! Ai obtinut Cartela Rosie.")
		are_cartela = true
		meniu_seif.hide() 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
		input_cod.text = "" 
	else:
		afiseaza_mesaj("Eroare! Cod gresit.")
		input_cod.text = "" 

func _on_button_close_pressed():
	meniu_seif.hide() 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
	input_cod.text = ""
