extends Area3D
signal step_completed

func _ready() -> void:
	add_to_group("targets")

func hit() -> void:
	emit_signal("step_completed")
	queue_free()
