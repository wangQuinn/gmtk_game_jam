extends Node

@export var minigame_container: Node3D
@export var character: Node3D  # drag your `character` node here in Inspector

var level_data = {
	10: ["res://minigames/TargetPractice.tscn"],
	9:  ["res://minigames/TargetPractice.tscn"],
	# add more levels/minigames as your team builds them
}

var current_level = 10
var queue: Array = []

func _ready() -> void:
	start_level(current_level)

func start_level(level: int) -> void:
	print(current_level)
	queue = level_data[level].duplicate()
	_load_next_minigame()

func _load_next_minigame() -> void:
	if queue.is_empty():
		_level_complete()
		return

	var path = queue.pop_front()
	var scene = load(path).instantiate()
	minigame_container.add_child(scene)

	if character.has_signal("target_hit") and scene.has_method("_on_target_hit"):
		character.target_hit.connect(scene._on_target_hit)

	scene.minigame_finished.connect(_on_minigame_finished.bind(scene))
	scene.setup(current_level)
	scene.start_minigame()

func _on_minigame_finished(minigame_node: Node) -> void:
	minigame_node.queue_free()
	_load_next_minigame()

func _level_complete() -> void:
	current_level -= 1
	if current_level >= 1:
		start_level(current_level)
	else:
		print("Game complete!")
