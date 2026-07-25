extends MinigameBase
## Minimal version: shows the head, cycles mouth open/close.
## Ends automatically after a fixed duration.

@export var mouth_controller_path: NodePath = "MouthControl"
@export var cavity_spawn_path: NodePath = "ToothSlots"
@export var stay_duration: float = 7.0

var speed_multiplier: float = 1.0
var time_remaining: float = 0.0

@onready var mouth_controller: Node = get_node(mouth_controller_path)
@onready var cavity_spawner: Node = get_node(cavity_spawn_path)


func setup(level: int, speed: float = 1.0) -> void:
	speed_multiplier = speed
	super.setup(level)


func start_minigame() -> void:
	super.start_minigame()
	time_remaining = stay_duration
	
	cavity_spawner.generate(self)
	cavity_spawner.set_visible_and_shootable(false)

	mouth_controller.mouth_opened.connect(_on_mouth_opened)
	mouth_controller.mouth_closed.connect(_on_mouth_closed)
	mouth_controller.start_cycle(speed_multiplier)


func _process(delta: float) -> void:
	if not _is_active:
		return

	time_remaining -= delta
	if time_remaining <= 0.0:
		time_remaining = 0.0
		mouth_controller.stop_cycle()
		finish_minigame()


func _on_mouth_opened() -> void:
	cavity_spawner.set_visible_and_shootable(true)


func _on_mouth_closed() -> void:
	cavity_spawner.set_visible_and_shootable(false)
	
func register_cavity_hit(_cavity: Node) -> void:
	if not _is_active:
		return

	print("Cavity hit registered! Remaining: ", cavity_spawner.remaining_cavities())

	if cavity_spawner.remaining_cavities() <= 0:
		print("All cavities cleared, finishing minigame")
		mouth_controller.stop_cycle()
		finish_minigame()
		
func register_tooth_hit(_tooth: Node) -> void:
	# hitting a good tooth does nothing for now -- add a "miss" sound/penalty later if you want
	pass
