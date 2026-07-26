extends Node
@export var minigame_container: Node3D
@export var character: Node3D
@export var level_label: Label
@export var start_target: Node3D   
@export var level_time_limit: float = 30.0 # seconds per level
@export var timer_label: Label #timer label

@onready var lose_label: Label = $"../HUD/Control/LoseLabel"
@onready var level_label2: Label = $"../HUD/Control/LevelLabel"
@onready var level_timer: Timer = Timer.new()
@onready var hat_target_label: Label = $"../HUD/Control/HatTargetLabel"
@onready var fade_overlay: ColorRect = $"../FadeOverlay"   
@onready var gun_ui: CanvasLayer = $"../character/Camera3D/GunUI"
@onready var gun_texture: TextureRect = $"../character/Camera3D/GunUI/GunTexture"

@onready var music_player: AudioStreamPlayer = $"../MusicPlayer"
@onready var ending_label: Label = $"../HUD/Control/EndingLabel"
@onready var ending_image: TextureRect = $"../HUD/Control/EndingImage"
@onready var restart_label: Label = $"../HUD/Control/RestartLabel"
var ending_active: bool = false

@onready var win_label: Label = $"../HUD/Control/WinLabel"
@onready var win_image: TextureRect = $"../HUD/Control/WinImage"
@onready var minigames_left_label: Label = $"../HUD/Control/MinigamesLeftLabel"
var timer_label_base_position : Vector2
var minigames_left_label_base_position : Vector2
@export var low_time_threshold : float = 10.0 #seconds remaining before urgent mode 

var isInverted = false;

var all_minigames: Array[String] = [
	"res://minigames/fish_finder/TargetPractice.tscn",
	"res://minigames/cavity_shooter/cavity_shooter.tscn",
	"res://minigames/fire/fire.tscn",
	"res://minigames/soul_tracker/soul_tracker.tscn",
]

var minigame_times: Dictionary = {
	"res://minigames/fish_finder/TargetPractice.tscn" : [10.0, "Shoot the Wanted Fish!"],
	"res://minigames/cavity_shooter/cavity_shooter.tscn" : [10.0, "Be a Dentist!"],
	"res://minigames/fire/fire.tscn": [20.0, "Put out the fire!"] ,
	"res://minigames/soul_tracker/soul_tracker.tscn": [20.0, "Ghosts! Happy!"],
}

var current_level = 9
var queue: Array = []
var total_minigames_in_level:int = 0
var current_minigame_index: int = 0

func _ready() -> void:
	character.set_process(false)
	character.set_physics_process(false)
	start_target.tutorial_complete.connect(_on_start_pressed)
	level_label2.hide()
	lose_label.hide()
	gun_ui.hide()
	minigames_left_label.hide()
	timer_label.hide()
	timer_label_base_position = timer_label.position
	minigames_left_label_base_position = minigames_left_label.position

	# nothing else happens until the sphere is shot
	add_child(level_timer)
	level_timer.one_shot = true
	level_timer.timeout.connect(_on_level_timeout)
	hat_target_label.hide()
	
	fade_overlay.modulate.a = 1.0
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "modulate:a", 0.0, 1.5)
	await fade_tween.finished
	fade_overlay.hide()
	
	gun_ui.show()
	gun_texture.modulate.a = 0.0
	var gun_tween = create_tween()
	gun_tween.tween_property(gun_texture, "modulate:a", 1.0, 0.6)
	
	music_player.play()

func _on_start_pressed() -> void:
	character.set_process(true)
	character.set_physics_process(true)
	start_level(current_level)

func start_level(level: int) -> void:
	character.invert_controls = (level == 3  or level ==7)
	if(level == 3 or level == 7):
		isInverted = true
	else:
		isInverted = false
	var count = randi_range(1, 3)
	queue = []
	for i in ceil((11 - level)/2):
		queue.append(all_minigames.pick_random())
	total_minigames_in_level = queue.size()
	current_minigame_index = 0
	show_level_intro(level)
	
func _process(_delta: float) -> void:
	if not level_timer.is_stopped():
		timer_label.text = "%.2f" % level_timer.time_left
		if level_timer.time_left <= low_time_threshold:
			timer_label.modulate = Color (1.0,0.2,0.2)
			var shake_strength = 4.0
			timer_label.position = timer_label_base_position + Vector2(
				randf_range(-shake_strength, shake_strength),
				randf_range(-shake_strength, shake_strength)
			)

func show_level_intro(level: int) -> void:
	level_label2.show() 
	var text = "LEVEL %d" % level
	if(isInverted):
		level_label2.text = reverse_string(text)
	else:
		level_label2.text = text
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
	level_label2.hide()
	level_label2.position = target_pos
	
	_load_next_minigame()

func _load_next_minigame() -> void:
	if queue.is_empty():
		_level_complete()
		return
	var path = queue.pop_front()
	print("Selected minigame: ", path)
	
	current_minigame_index += 1
	minigames_left_label.text = "%d/%d" % [current_minigame_index, total_minigames_in_level]
	minigames_left_label.show()
	_shake_label(minigames_left_label, minigames_left_label_base_position)
	
	var scene = load(path).instantiate()
	minigame_container.add_child(scene)
	character.hold_mode = (path == "res://minigames/fire/fire.tscn")
	var time_for_level = minigame_times.get(path, level_time_limit)[0]
	var text_for_level = minigame_times.get(path, "SHOOT!")[1]
	if(isInverted):
		lose_label.text = reverse_string(text_for_level)
	else:
		lose_label.text = text_for_level
	lose_label.show()
	
	if scene.has_signal("hat_prompt_ready"):
		scene.hat_prompt_ready.connect(_on_hat_prompt_ready)

	await get_tree().create_timer(1).timeout
	lose_label.hide()
	level_timer.start(time_for_level)
	timer_label.show()
	if character.has_signal("target_hit") and scene.has_method("_on_target_hit"):
		character.target_hit.connect(scene._on_target_hit)
	scene.minigame_finished.connect(_on_minigame_finished.bind(scene))
	scene.minigame_failed.connect(_on_minigame_failed.bind(scene))
	var speed = randf_range(0.8, 1.6)
	scene.setup(current_level, speed)
	scene.start_minigame()

func _on_hat_prompt_ready(hat_name: String) -> void:
	hat_target_label.text = "Find: %s" % hat_name
	hat_target_label.show()


func _on_minigame_finished(minigame_node: Node) -> void:
	timer_label.hide()
	hat_target_label.hide()
	level_timer.stop()
	minigame_node.queue_free()
	_load_next_minigame()
	
func _on_minigame_failed(minigame_node: Node) -> void:
	timer_label.hide()
	hat_target_label.hide()
	level_timer.stop()
	minigame_node.queue_free()

	if current_level + 1 >= 10:
		_trigger_bad_ending()
		return


	lose_label.text = "YOU LOOSE :("
	print("YOU LOOSE :(")
	lose_label.show()
	await get_tree().create_timer(1).timeout
	lose_label.hide()

	current_level = min(current_level + 1, 9)
	start_level(current_level)

func _level_complete() -> void:
	minigames_left_label.hide()
	current_level -= 1
	if current_level >= 1:
		start_level(current_level)
	else:
		_trigger_win_ending()
		
func _on_level_timeout() -> void:
	timer_label.hide()
	if current_level == 9:
		_trigger_bad_ending()
		return
	print("YOU LOOSE.")
	queue.clear()
	for child in minigame_container.get_children():
		child.queue_free()
	lose_label.show()
	await get_tree().create_timer(1).timeout
	lose_label.hide()
	current_level = min(current_level + 1, 9)
	start_level(current_level)
	
func _trigger_bad_ending() -> void:
	queue.clear()
	for child in minigame_container.get_children():
		child.queue_free()
		
	hat_target_label.hide()
	timer_label.hide()
	
	character.set_process(false)
	character.set_physics_process(false)
	
	# fade gun out alongside fade to black
	var gun_fade_tween = create_tween()
	gun_fade_tween.tween_property(gun_texture, "modulate:a", 0.0, 1.0)
	
	fade_overlay.show()
	fade_overlay.modulate.a = 0.0
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.5)
	await fade_tween.finished
	
	gun_ui.hide()
	
	# show ending text
	ending_label.text = "... kitty has fallen to the 10th floor of hell and is now stuck there for eternity"
	ending_label.modulate.a = 0.0
	ending_label.show()
	var text_tween = create_tween()
	text_tween.tween_property(ending_label, "modulate:a", 1.0, 1.0)
	await text_tween.finished
	
	await get_tree().create_timer(2.0).timeout
	
	# then show the image
	ending_image.modulate.a = 0.0
	ending_image.show()
	var image_tween = create_tween()
	image_tween.tween_property(ending_image, "modulate:a", 1.0, 1.0)
	await image_tween.finished
	
	await get_tree().create_timer(1.5).timeout
	
	# show restart prompt
	restart_label.text = "Press SPACE to play again"
	restart_label.modulate.a = 0.0
	restart_label.show()
	var restart_tween = create_tween()
	restart_tween.tween_property(restart_label, "modulate:a", 1.0, 0.8)
	await restart_tween.finished
	
	ending_active = true

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if ending_active and event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_tree().change_scene_to_file("res://main.tscn")

func _shake_label(label: Label, base_pos: Vector2, strength: float = 6.0, duration: float = 0.3) -> void:
	var tween = create_tween()
	var shakes = 6
	for i in shakes:
		var offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		tween.tween_property(label, "position", base_pos + offset, duration / shakes)
	tween.tween_property(label, "position", base_pos, duration / shakes)

func _trigger_win_ending() -> void:
	queue.clear()
	for child in minigame_container.get_children():
		child.queue_free()
	
	hat_target_label.hide()
	timer_label.hide()
	
	character.set_process(false)
	character.set_physics_process(false)
	
	# fade gun out alongside fade to black
	var gun_fade_tween = create_tween()
	gun_fade_tween.tween_property(gun_texture, "modulate:a", 0.0, 1.0)
	
	fade_overlay.show()
	fade_overlay.modulate.a = 0.0
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.5)
	await fade_tween.finished
	
	gun_ui.hide()
	
	# show winning text
	win_label.text = "Kitty has done enough good deeds... all nine lives are restored!"
	win_label.modulate.a = 0.0
	win_label.show()
	var text_tween = create_tween()
	text_tween.tween_property(win_label, "modulate:a", 1.0, 1.0)
	await text_tween.finished
	
	await get_tree().create_timer(2.0).timeout
	
	# then show the win image
	win_image.modulate.a = 0.0
	win_image.show()
	var image_tween = create_tween()
	image_tween.tween_property(win_image, "modulate:a", 1.0, 1.0)
	await image_tween.finished
	
	await get_tree().create_timer(1.5).timeout
	
	print("About to show restart label")

	restart_label.text = "Press SPACE to play again"
	restart_label.modulate.a = 0.0
	restart_label.show()
	var restart_tween = create_tween()
	restart_tween.tween_property(restart_label, "modulate:a", 1.0, 0.8)
	await restart_tween.finished
	print("Restart label should be visible now")

	ending_active = true
	
func reverse_string(input: String) -> String:
	var characters := input.split("")
	characters.reverse()
	return "".join(characters)
