extends Node
@export var minigame_container: Node3D
@export var character: Node3D
@export var level_label: Label
@export var start_target: Area3D   # NEW — drag StartTarget here

var all_minigames: Array[String] = [
	"res://minigames/fish_finder/TargetPractice.tscn",
	"res://minigames/cavity_shooter/cavity_shooter.tscn",

]

var current_level = 10
var queue: Array = []

func _ready() -> void:
	character.set_process(false)
	character.set_physics_process(false)
	start_target.start_pressed.connect(_on_start_pressed)
	# nothing else happens until the sphere is shot

func _on_start_pressed() -> void:
	character.set_process(true)
	character.set_physics_process(true)
	start_level(current_level)

func start_level(level: int) -> void:
	var count = randi_range(1, 3)
	queue = []
	for i in count:
		queue.append(all_minigames.pick_random())
	show_level_intro(level)

func show_level_intro(level: int) -> void:
	level_label.show() 
	level_label.text = "LEVEL %d" % level
	level_label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(level_label, "modulate:a", 1.0, 0.4)
	tween.tween_interval(0.8)
	tween.tween_property(level_label, "modulate:a", 0.0, 0.4)
	await tween.finished
	level_label.hide()
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
	var speed = randf_range(0.8, 1.6)
	scene.setup(current_level, speed)
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
