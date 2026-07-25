extends Control

@onready var fire_flicker: TextureRect = $FireFlicker
@onready var title: TextureRect = $TitleImage   # updated to match new node name/type

var fire_tex: Texture2D = preload("res://minigames/intro_story/fire.png")
var nofire_tex: Texture2D = preload("res://minigames/intro_story/nofire.png")

@export var flicker_count: int = 8          # how many times it flickers
@export var flicker_interval: float = 0.20  # seconds between each swap

func _ready() -> void:
	title.modulate.a = 0.0
	title.hide()
	play_intro()

func play_intro() -> void:
	for i in flicker_count:
		fire_flicker.texture = fire_tex if i % 2 == 0 else nofire_tex
		await get_tree().create_timer(flicker_interval).timeout

	# settle on the "lit" version at the end, or hide it — your call
	fire_flicker.texture = fire_tex

	await get_tree().create_timer(0.3).timeout  # small pause before title

	title.show()
	var tween = create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 0.6)
	await tween.finished

	await get_tree().create_timer(1.0).timeout
	_on_intro_finished()

func _on_intro_finished() -> void:
	get_tree().change_scene_to_file("res://minigames/comic_story/ComicIntro.tscn")
