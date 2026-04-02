extends OmniLight3D

func _ready() -> void:
	pass 

func _process(_delta):
	
	if randf() > 0.95: 
		light_energy = randf_range(0.1, 0.5)
