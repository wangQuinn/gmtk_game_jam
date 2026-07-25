extends Area3D
signal target_hit(target: Node)
var minigame: Node = null
var spawner: Node = null


func _ready() -> void:
	add_to_group("targets")
	add_to_group("cavity")


func hit() -> void:
	target_hit.emit(self)
	if spawner and spawner.has_method("notify_cavity_hit"):
		spawner.notify_cavity_hit(self)          # remove from tracking FIRST
	if minigame and minigame.has_method("register_cavity_hit"):
		minigame.register_cavity_hit(self)       # THEN check remaining count
	queue_free()
