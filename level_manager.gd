extends Node
@export var minigame_container: Node3D
@export var character: Node3D
@export var level_label: Label
@export var start_target: Area3D   # NEW — drag StartTarget here

@onready var level_label2: Label = $"../HUD/LevelLabel"

var all_minigames: Array[String] = [
	"res://minigames/fish_finder/TargetPractice.tscn",
	"res://minigames/cavity_shooter/cavity_shooter.tscn",
	#"res://minigames/timer_countdown/timer_countdown.tscn",
]

var current_level = 10
var queue: Array = []

func _ready() -> void:
	character.set_process(false)
	character.set_physics_process(false)
	start_target.start_pressed.connect(_on_start_pressed)
	level_label2.hide()
	
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
	level_label2.show() 
	
	level_label2.text = "LEVEL %d" % level
	
	var target_pos: Vector2 = level_label2.position
	var start_pos: Vector2 = target_pos + Vector2(0,-200)
	var end_pos: Vector2 = target_pos + Vector2(0,500) 
	level_label2.position = start_pos
	level_label2.modulate.a = 1.0  # no fade this time, it's a slide

	var tween = create_tween()
	tween.tween_property(level_label2, "position", target_pos, 0.4)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.8)
	tween.tween_property(level_label2, "position", end_pos, 0.4)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	
	await tween.finished
	
	level_label2.position = target_pos
	level_label.hide()
	
	_load_next_minigame()

func _load_next_minigame() -> void:
	if queue.is_empty():
		_level_complete()
		return
	var path = queue.pop_front()
	print("Selected minigame: ", path)
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
		
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
