extends Area3D

signal target_hit(target: Area3D)

func _ready() -> void:
	add_to_group("targets")

func hit() -> void:
	target_hit.emit(self)
	queue_free()
