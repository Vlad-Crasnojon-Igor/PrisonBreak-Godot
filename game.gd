extends Node3D

# AI grijă ca numele fișierului să fie EXACT cum l-ai salvat tu (ex: Baterie.tscn)
var scena_baterie = preload("res://Baterie.tscn") 

func _ready():
	# Amestecăm zarurile hărții
	randomize()
	
	# Chemăm funcția care pune bateriile pe masă
	spawn_baterii()

func spawn_baterii():
	var puncte = $LocatiiBaterii.get_children()
	
	
	if puncte.size() == 0:
		return
		
	
	puncte.shuffle()
	
	var numar_baterii = 2
	
	for i in range(numar_baterii):
		if i < puncte.size():
			var baterie_noua = scena_baterie.instantiate()
			add_child(baterie_noua)
			# O punem exact în locația Marker-ului i
			baterie_noua.global_position = puncte[i].global_position
