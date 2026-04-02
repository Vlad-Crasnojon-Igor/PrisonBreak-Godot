extends StaticBody3D

func interact():
	print("Am găsit o componentă!")
	var quest_ui = get_tree().get_first_node_in_group("InterfataQuest")
	
	if quest_ui != null:
		quest_ui.adauga_componenta()
		
	queue_free()
