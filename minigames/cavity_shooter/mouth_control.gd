extends Node3D
## Attach to MouthControl. Drives randomized mouth open/close timing by
## seeking a single "MouthMovement" animation to its open/closed keyframes.

signal mouth_opened
signal mouth_closed

@export var animation_player_path: NodePath = "../AnimationPlayer"
@export var animation_name: String = "MouthMovement"
@export var closed_time_in_anim: float = 0.0   # seconds into the animation where mouth is closed
@export var open_time_in_anim: float = 0.4    # seconds into the animation where mouth is open

@export var min_open_time: float = 2.5
@export var max_open_time: float = 4.0
@export var min_closed_time: float = 1.5
@export var max_closed_time: float = 3.0

@export var min_time_scale: float = 0.4

var speed_multiplier: float = 1.0
var is_open: bool = false
var is_running: bool = false

@onready var animation_player: AnimationPlayer = get_node_or_null(animation_player_path)


func _ready() -> void:
	if animation_player == null:
		push_warning("MouthControl: AnimationPlayer not found at path: %s" % animation_player_path)
	else:
		print("MouthControl: found AnimationPlayer with animations: ", animation_player.get_animation_list())
		if animation_player.has_animation(animation_name):
			# Play once so the animation is "active", then immediately pause on the closed frame
			animation_player.play(animation_name)
			animation_player.seek(closed_time_in_anim, true)
			animation_player.pause()


func start_cycle(speed: float = 1.0) -> void:
	speed_multiplier = speed
	is_running = true
	_run_cycle()


func stop_cycle() -> void:
	is_running = false


func _current_time_scale() -> float:
	var time_scale = 1.0 / speed_multiplier
	return max(time_scale, min_time_scale)


func _run_cycle() -> void:
	while is_running:
		var time_scale = _current_time_scale()

		var closed_time = randf_range(min_closed_time, max_closed_time) * time_scale
		await get_tree().create_timer(closed_time).timeout
		if not is_running:
			return
		_open_mouth()

		var open_time = randf_range(min_open_time, max_open_time) * time_scale
		await get_tree().create_timer(open_time).timeout
		if not is_running:
			return
		_close_mouth()


func _open_mouth() -> void:
	is_open = true
	_seek_to(open_time_in_anim)
	emit_signal("mouth_opened")


func _close_mouth() -> void:
	is_open = false
	_seek_to(closed_time_in_anim)
	emit_signal("mouth_closed")


func _seek_to(time_in_seconds: float) -> void:
	if animation_player and animation_player.has_animation(animation_name):
		animation_player.seek(time_in_seconds, true)
		animation_player.pause()
