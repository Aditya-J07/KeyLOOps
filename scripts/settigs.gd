extends Node2D

@onready var color_slider = $ColorSlider
@onready var display_label = $DisplayLabel
@onready var hide_sprite: Button = $HideSprite
@onready var mute: CheckButton = $Mute
@onready var mute_2: CheckButton = $Mute2
@onready var effect: CanvasLayer = %effect
@onready var volume: HSlider = $volume

var music_player = GameMusicLoop7145285
var vol_value : float = Global.volume

func _ready():
	# Slider setup
	color_slider.min_value = 0
	color_slider.max_value = 360
	color_slider.step = 1

	# Load previous color hue
	var hue = rgb_to_hsv(Global.text_color).x
	color_slider.value = hue * 360
	update_display_color(Global.text_color)
	
	hide_sprite.button_pressed = Global.sunrays_on_off
	mute.button_pressed = Global.mute
	mute_2.button_pressed = Global.crt
	volume.value = Global.volume
	
	if Global.crt == true :
		effect.visible = true
	else:
		effect.visible = false

func _process(delta: float) -> void:
	if Global.sunrays_on_off == false :
		hide_sprite.text = "Hide Rays"
	else :
		hide_sprite.text = "Show Rays"
	if Global.crt == true :
		effect.visible = true
	else:
		effect.visible = false


func update_display_color(color: Color) -> void:
	display_label.add_theme_color_override("font_color", color)

# --- Utility to get HSV from a Color in Godot ---
func rgb_to_hsv(c: Color) -> Vector3:
	var r = c.r
	var g = c.g
	var b = c.b
	var max_c = max(r, g, b)
	var min_c = min(r, g, b)
	var delta = max_c - min_c
	
	var h = 0.0
	if delta != 0:
		if max_c == r:
			h = fmod((g - b) / delta, 6.0)
		elif max_c == g:
			h = ((b - r) / delta) + 2.0
		elif max_c == b:
			h = ((r - g) / delta) + 4.0
		h /= 6.0
	if h < 0:
		h += 1.0
	
	var s = 0.0 if max_c == 0 else delta / max_c
	var v = max_c
	return Vector3(h, s, v)



func _on_color_slider_value_changed(value: float) -> void:
	var hue = value / 360.0
	var color = Color.from_hsv(hue, 1.0, 1.0)
	Global.text_color = color
	update_display_color(color)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start screen.tscn")




func _on_hide_sprite_toggled(toggled_on: bool) -> void:
	Global.sunrays_on_off = toggled_on
	

func _on_mute_toggled(toggled_on: bool) -> void:
	Global.mute = toggled_on


func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("bgm"),linear_to_db(value))
	vol_value = value
	Global.volume = vol_value
	

func _on_mute_2_toggled(toggled_on: bool) -> void:
	Global.crt = toggled_on
