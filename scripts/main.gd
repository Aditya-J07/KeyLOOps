extends Node

@onready var display_label = $VBoxContainer/DisplayLabel
@onready var timer = $Timer
@onready var score_label: Label = $ScoreLabel
@onready var camera = $Camera2D
@onready var correct_sound = $CorrectSound
@onready var wrong_sound = $WrongSound
@onready var milestone_sound = $MilestoneSound
@onready var red_flash = $RedFlash
@onready var tick_sprite = $TickSprite
@onready var cross_sprite = $CrossSprite
@onready var progress_label: Label = $ProgressLabel
@onready var sun_rays: Sprite2D = $SunRays
@onready var effect: CanvasLayer = $effect

var audio_server = AudioServer
var bus_index = audio_server.get_bus_index("sfx")


var key_list = [
	"w", "a", "s", "d", "j", "k", "l", "q", "e", "z", "x", "c",
	"1", "2", "3", "4", "5"
]

var score = -1
var sequence = []
var player_input = []
var showing_sequence = false
var new_game = true
var high_score_beaten = false

func _ready():
		# Apply saved color from settings
	sun_rays.visible = not Global.sunrays_on_off
	if display_label:
		display_label.add_theme_color_override("font_color", Global.text_color)
	if progress_label:
		progress_label.add_theme_color_override("font_color",Global.text_color)
	if score_label:
		score_label.add_theme_color_override("font_color",Global.text_color)
	if tick_sprite:
		tick_sprite.modulate = Global.text_color
	if cross_sprite:
		cross_sprite.modulate = Global.text_color
	if Global.crt == true :
		effect.visible = true
	else:
		effect.visible = false
		
	if Global.mute == false:
		audio_server.set_bus_mute(bus_index, true)

	tick_sprite.visible = false
	cross_sprite.visible = false
	start_new_game()
	

func _process(delta: float) -> void:
	sun_rays.visible = not Global.sunrays_on_off
		

func start_new_game():
	sequence.clear()
	player_input.clear()
	score = -1
	high_score_beaten = false
	new_game = true
	tick_sprite.visible = false
	cross_sprite.visible = false
	await add_new_key()
	await show_sequence()

func add_new_key():
	var keys_to_add = 1
	if score >= 5:
		keys_to_add = randi() % 3 + 1

	for i in range(keys_to_add):
		var new_key = key_list[randi() % key_list.size()]
		sequence.append(new_key)

	score += 1
	score_label.text = "Score: %d" % score

	if score > 0 and score % 5 == 0:
		milestone_sound.play()

	if score > Global.high_score and not high_score_beaten:
		high_score_beaten = true
		bounce_score_label()

func get_key_name(event: InputEventKey) -> String:
	return OS.get_keycode_string(event.physical_keycode).to_lower()

func _unhandled_input(event):
	if showing_sequence or !event is InputEventKey or !event.pressed:
		return

	# Accept only A-Z (KEY_A to KEY_Z) and 1–9 (KEY_1 to KEY_9)
	var key = event.keycode
	var is_letter = key >= KEY_A and key <= KEY_Z
	var is_number = key >= KEY_1 and key <= KEY_9

	if not (is_letter or is_number):
		# Ignore other keys like volume, media, function keys, etc.
		return

	var key_name = OS.get_keycode_string(event.keycode).to_lower()

	if key_name not in key_list:
		if score > Global.high_score:
			Global.high_score = score
		await handle_wrong_input()
		await get_tree().create_timer(1.0).timeout
		start_new_game()
		return

	player_input.append(key_name)
	update_progress_display()

	var index = player_input.size() - 1
	if player_input[index] != sequence[index]:
		if score > Global.high_score:
			Global.high_score = score
		await handle_wrong_input()
		await get_tree().create_timer(2.0).timeout
		start_new_game()
		return

	if player_input.size() == sequence.size():
		await handle_correct_input()
		await add_new_key()
		await show_sequence()

func show_sequence():
	showing_sequence = true
	display_label.text = ""
	tick_sprite.visible = false
	cross_sprite.visible = false

	progress_label.visible = false  # 🔴 Hide progress while showing sequence

	if new_game:
		display_label.text = "Get Ready!"
		await get_tree().create_timer(1.5).timeout
		new_game = false

	for key in sequence:
		display_label.text = key.to_upper()
		await get_tree().create_timer(0.6).timeout
		display_label.text = ""
		await get_tree().create_timer(0.3).timeout

	display_label.text = "Your turn!"
	player_input.clear()

	progress_label.visible = true  # 🟢 Show progress now
	update_progress_display()

	showing_sequence = false


func handle_wrong_input():
	tick_sprite.visible = false
	cross_sprite.visible = true
	display_label.text = ""
	wrong_sound.play()
	flash_red()
	shake_screen()
	await get_tree().create_timer(0.5).timeout
	cross_sprite.visible = false

func handle_correct_input():
	cross_sprite.visible = false
	tick_sprite.visible = true
	display_label.text = ""
	correct_sound.play()
	zoom_camera_slightly()
	await get_tree().create_timer(0.5).timeout
	tick_sprite.visible = false

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start screen.tscn")

func shake_screen():
	var tween = create_tween()
	for i in range(3):
		var offset = Vector2(
			randf_range(-10, 10),
			randf_range(-10, 10)
		)
		tween.tween_property(camera, "offset", offset, 0.05)
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)

func zoom_camera_slightly():
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(0.98, 0.98), 0.05)
	tween.tween_property(camera, "zoom", Vector2(1, 1), 0.1)

func bounce_score_label():
	var tween = create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(score_label, "scale", Vector2(1, 1), 0.1)

func flash_red():
	if red_flash == null:
		return

	red_flash.modulate = Color(1, 0, 0, 0)
	var tween := get_tree().create_tween()
	tween.tween_property(red_flash, "modulate:a", 0.5, 0.05)
	tween.tween_property(red_flash, "modulate:a", 0.0, 0.3)

func update_progress_display():
	var progress = ""
	for i in range(sequence.size()):
		if i < player_input.size():
			progress += "•"  # Dot for entered keys
		else:
			progress += "-"  # Dash for remaining
	progress_label.text = progress.strip_edges()
