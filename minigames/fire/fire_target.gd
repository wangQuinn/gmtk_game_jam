extends Area3D
signal extinguished

@export var hits_to_extinguish: int = 30
@export var min_scale: float = 0.2   # how small it gets right before vanishing
@onready var fire_mesh: Node3D = $Sketchfab_Scene   # adjust to your actual model node name

var hits := 0
var base_scale: Vector3

func _ready() -> void:
	add_to_group("targets")
	base_scale = fire_mesh.scale

func hit() -> void:
	hits += 1
	_update_scale()
	if hits >= hits_to_extinguish:
		extinguished.emit()
		queue_free()

func _update_scale() -> void:
	var ratio = 1.0 - (float(hits) / float(hits_to_extinguish))
	var scale_factor = lerp(min_scale, 1.0, ratio)
	fire_mesh.scale = base_scale * scale_factor
