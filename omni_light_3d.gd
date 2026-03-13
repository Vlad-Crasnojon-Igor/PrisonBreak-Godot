extends OmniLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Schimbă energia la întâmplare între 0.2 și 0.5
	if randf() > 0.95: # 5% șansă la fiecare cadru să schimbe lumina
		light_energy = randf_range(0.1, 0.5)
