extends Area3D

signal start_pressed

func _ready():
	add_to_group("targets")

func hit():
	emit_signal("start_pressed")
	queue_free()
