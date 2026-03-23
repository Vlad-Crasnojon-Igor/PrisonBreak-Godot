extends CharacterBody3D

var viteza_mers = 5.0
var viteza_crouch = 2.0
var viteza_curenta = 5.0 
const JUMP_VELOCITY = 4.5

var interval_pasi = 0.5
var timer_pasi = 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = 0.002 

@onready var sistem_inventar = $SistemInventar
@onready var sistem_interactiune = $SistemInteractiune

@onready var sistem_lanterna = $SistemLanterna
@onready var sunet_pasi = $SunetPasi
@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var mesaj_ui = $CanvasLayer2/MesajUI
@onready var hitbox = $CollisionShape3D 
@onready var meniu_seif = $CanvasLayer2/MeniuSeif
@onready var input_cod = $CanvasLayer2/MeniuSeif/InputCod


func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mesaj_ui.hide()
	meniu_seif.hide()

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
		sistem_lanterna.comuta_lanterna()
		
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("move_left", "move_right", "move_foward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if sistem_interactiune.este_ascuns == false:
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

	if direction and is_on_floor() and viteza_curenta == viteza_mers and sistem_interactiune.este_ascuns == false:
		timer_pasi -= delta 
		
		if timer_pasi <= 0:
			sunet_pasi.play() 
			timer_pasi = interval_pasi 
	else:
		timer_pasi = 0.0
		
	if Input.is_action_just_pressed("interact"):
		sistem_interactiune.incearca_interactiune()

	move_and_slide()

func afiseaza_mesaj(text_nou):
	mesaj_ui.text = text_nou
	mesaj_ui.show()
	await get_tree().create_timer(3.0).timeout
	mesaj_ui.hide()

func _on_button_open_pressed():
	if input_cod.text == "421":
		afiseaza_mesaj("Cod Corect! Ai obtinut Cartela Rosie.")
		sistem_inventar.are_cartela = true
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
