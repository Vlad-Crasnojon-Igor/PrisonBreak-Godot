extends CharacterBody3D

# Am transformat SPEED în variabile ca să le putem schimba în timp ce jucăm
var viteza_mers = 5.0
var viteza_crouch = 2.0
var viteza_curenta = 5.0 
const JUMP_VELOCITY = 4.5

var bucati_cod = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = 0.002 

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var mesaj_ui = $CanvasLayer2/MesajUI
@onready var hitbox = $CollisionShape3D 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mesaj_ui.hide()

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	# --- SISTEMUL DE CROUCH (Mers pe vine) ---
	if Input.is_action_pressed("move_crouch"):
		viteza_curenta = viteza_crouch
		# Micșorăm capsula și coborâm camera lin
		hitbox.shape.height = move_toward(hitbox.shape.height, 1.0, delta * 4.0)
		camera.position.y = move_toward(camera.position.y, 0.0, delta * 4.0)
	else:
		viteza_curenta = viteza_mers
		# Revenim la înălțimea normală
		hitbox.shape.height = move_toward(hitbox.shape.height, 2.0, delta * 4.0)
		camera.position.y = move_toward(camera.position.y, 0.5, delta * 4.0)
	# ----------------------------------------

	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_left", "move_right", "move_foward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * viteza_curenta # Folosim viteza curentă
		velocity.z = direction.z * viteza_curenta
	else:
		velocity.x = move_toward(velocity.x, 0, viteza_curenta)
		velocity.z = move_toward(velocity.z, 0, viteza_curenta)
		
	if Input.is_action_just_pressed("interact"):
		if raycast.is_colliding():
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
					afiseaza_mesaj("Ai descuiat usa...")
					get_tree().change_scene_to_file("res://game.tscn") 
				else:
					afiseaza_mesaj("Usa e blocata. Mai cauta...")

	move_and_slide()

func afiseaza_mesaj(text_nou):
	mesaj_ui.text = text_nou
	mesaj_ui.show()
	await get_tree().create_timer(3.0).timeout
	mesaj_ui.hide()
