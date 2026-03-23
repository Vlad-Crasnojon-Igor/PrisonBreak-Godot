extends Node3D

var numar_baterii = 2
var scena_baterie = preload("res://scene/baterie.tscn")
func _ready():
	randomize()
	spawn_baterii()

func spawn_baterii():
	var puncte = $LocatiiBaterii.get_children()
	if puncte.size() == 0:
		return
	puncte.shuffle()
	
	
	for i in range(numar_baterii):
		if i < puncte.size():
			var baterie_noua = scena_baterie.instantiate()
			add_child(baterie_noua)
			# O punem exact în locația Marker-ului i
			baterie_noua.global_position = puncte[i].global_position
