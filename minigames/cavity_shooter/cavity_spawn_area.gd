extends Node3D
## Attach to ToothSlots. Spawns cavities at a random subset of slots,
## and fills all remaining slots with good teeth.

@export var cavity_scene: PackedScene
@export var tooth_scene: PackedScene
@export var cavity_count: int = 2
@export var spawn_container_path: NodePath = "SpawnedCavities"

var spawned_cavities: Array = []
var spawned_teeth: Array = []
var minigame_ref: Node = null

@onready var spawn_container: Node = get_node(spawn_container_path)


func generate(minigame: Node, level: int) -> void:
	minigame_ref = minigame
	
	if level >= 7:
		cavity_count = 2
	elif level >= 5:
		cavity_count = 3
	else:
		cavity_count = 3 + (5 - level)
	
	_clear()

	var slots: Array = []
	for child in get_children():
		if child == spawn_container:
			continue
		slots.append(child)

	slots.shuffle()
	var chosen_count = min(cavity_count, slots.size())

	# First N shuffled slots become cavities
	for i in range(chosen_count):
		var slot = slots[i]
		var instance = cavity_scene.instantiate()
		spawn_container.add_child(instance)
		instance.global_position = slot.global_position
		instance.rotation.y = randf_range(0, TAU)
		instance.minigame = minigame_ref
		instance.spawner = self
		spawned_cavities.append(instance)

	# Remaining slots become good teeth
	for i in range(chosen_count, slots.size()):
		var slot = slots[i]
		var instance = tooth_scene.instantiate()
		spawn_container.add_child(instance)
		instance.global_position = slot.global_position
		instance.rotation.y = randf_range(0, TAU)
		instance.minigame = minigame_ref
		instance.spawner = self
		spawned_teeth.append(instance)


func _clear() -> void:
	for node in spawned_cavities:
		if is_instance_valid(node):
			node.queue_free()
	spawned_cavities.clear()

	for node in spawned_teeth:
		if is_instance_valid(node):
			node.queue_free()
	spawned_teeth.clear()


func remaining_cavities() -> int:
	return spawned_cavities.size()


func notify_cavity_hit(cavity: Node) -> void:
	spawned_cavities.erase(cavity)


func notify_tooth_hit(tooth: Node) -> void:
	spawned_teeth.erase(tooth)


func set_visible_and_shootable(enabled: bool) -> void:
	for node in spawned_cavities:
		_toggle_node(node, enabled)
	for node in spawned_teeth:
		_toggle_node(node, enabled)


func _toggle_node(node: Node, enabled: bool) -> void:
	if not is_instance_valid(node):
		return
	node.visible = enabled
	for child in node.get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", not enabled)
