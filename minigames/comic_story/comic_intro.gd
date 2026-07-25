extends Control

@onready var panels: Array[TextureRect] = [
	$panel1, $panel2, $panel3, $panel4,
	$panel5, $panel6, $panel7
]
@onready var text_screen: Control = $TextScreen
@onready var story_label: RichTextLabel = $TextScreen/StoryLabel

@export var reveal_interval: float = 0.3   # time between panel reveals
@export var story_text: String = "Kitty has been bad, to hell he goes"
func _ready() -> void:
	for p in panels:
		p.modulate.a = 0.0   # start all panels invisible

	text_screen.modulate.a = 0.0
	text_screen.hide()

	play_comic()

func play_comic() -> void:
	for p in panels:
		var tween = create_tween()
		tween.tween_property(p, "modulate:a", 1.0, 0.4)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tween.finished
		await get_tree().create_timer(reveal_interval).timeout

	await get_tree().create_timer(0.6).timeout
	show_text_screen()

func show_text_screen() -> void:
	story_label.text = story_text
	text_screen.show()
	var tween = create_tween()
	tween.tween_property(text_screen, "modulate:a", 1.0, 0.6)
	await tween.finished

	await get_tree().create_timer(2.5).timeout   # how long the text stays up, or wait for input instead
	_on_intro_finished()

func _on_intro_finished() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed or event is InputEventKey and event.pressed:
		# optional: let player skip the whole intro sequence
		_on_intro_finished()
