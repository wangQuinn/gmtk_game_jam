extends Area3D

signal target_hit(target: Node)

func hit() -> void:
	target_hit.emit(self)
