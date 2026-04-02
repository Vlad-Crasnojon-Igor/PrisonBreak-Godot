extends Node3D

var numar_baterii = 2
var scena_baterie = preload("res://scene/baterie.tscn")

var numar_componente = 3
var scena_componenta = preload("res://scene/componenta.tscn") 

func _ready():
	randomize()
	spawn_baterii()
	spawn_componente() 

func spawn_baterii():
	var puncte = $LocatiiBaterii.get_children()
	if puncte.size() == 0:
		return
	puncte.shuffle()
	
	for i in range(numar_baterii):
		if i < puncte.size():
			var baterie_noua = scena_baterie.instantiate()
			add_child(baterie_noua)
			baterie_noua.global_position = puncte[i].global_position


func spawn_componente():
	var puncte = $SpawnersComponente.get_children() 
	
	if puncte.size() == 0:
		print("Nu ai pus markere în SpawnersComponente!")
		return
		
	puncte.shuffle()
	
	for i in range(numar_componente):
		if i < puncte.size():
			var piesa_noua = scena_componenta.instantiate()
			add_child(piesa_noua)
			piesa_noua.global_position = puncte[i].global_position
