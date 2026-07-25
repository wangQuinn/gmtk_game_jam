extends Area3D
signal target_hit(target: Node)
var minigame: Node = null
var spawner: Node = null


func _ready() -> void:
	add_to_group("targets")
	# no "cavity" group -- this is a good tooth, hitting it shouldn't count toward winning


func hit() -> void:
	target_hit.emit(self)
	if spawner and spawner.has_method("notify_tooth_hit"):
		spawner.notify_tooth_hit(self)
	if minigame and minigame.has_method("register_tooth_hit"):
		minigame.register_tooth_hit(self)
	queue_free()
