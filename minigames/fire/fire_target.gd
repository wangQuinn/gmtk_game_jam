extends Area3D
signal extinguished

@export var hits_to_extinguish: int = 30
var hits := 0

func _ready() -> void:
	add_to_group("targets")
	
func hit() -> void:
	hits += 1
	if hits >= hits_to_extinguish:
		extinguished.emit()
		queue_free()
