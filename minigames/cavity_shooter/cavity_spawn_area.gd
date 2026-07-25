extends Node3D
## Attach to ToothSlots. Spawns cavities at a random subset of the
## manually-placed child slot positions.

@export var cavity_scene: PackedScene
@export var cavity_count: int = 3
@export var spawn_container_path: NodePath = "SpawnedCavities"

var spawned_cavities: Array = []
var minigame_ref: Node = null

@onready var spawn_container: Node = get_node(spawn_container_path)


func generate(minigame: Node) -> void:
	minigame_ref = minigame
	_clear()

	var slots: Array = []
	for child in get_children():
		if child == spawn_container:
			continue
		slots.append(child)

	slots.shuffle()
	var chosen_count = min(cavity_count, slots.size())

	for i in range(chosen_count):
		var slot = slots[i]
		var instance = cavity_scene.instantiate()
		spawn_container.add_child(instance)
		instance.global_position = slot.global_position
		instance.rotation.y = randf_range(0, TAU)
		instance.minigame = minigame_ref
		instance.spawner = self          # <-- add this line
		spawned_cavities.append(instance)


func _clear() -> void:
	for node in spawned_cavities:
		if is_instance_valid(node):
			node.queue_free()
	spawned_cavities.clear()


func remaining_cavities() -> int:
	return spawned_cavities.size()


func notify_cavity_hit(cavity: Node) -> void:
	spawned_cavities.erase(cavity)


func set_visible_and_shootable(enabled: bool) -> void:
	for node in spawned_cavities:
		if not is_instance_valid(node):
			continue
		node.visible = enabled
		for child in node.get_children():
			if child is CollisionShape3D:
				child.set_deferred("disabled", not enabled)
