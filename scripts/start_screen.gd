extends Node

@onready var high_score_label = $HighScoreLabel
@onready var effect: CanvasLayer = $effect

var audio_server = AudioServer
var bus_index = audio_server.get_bus_index("sfx")

func _ready():
	high_score_label.text = "High Score: %d" % Global.high_score
	if Global.mute == false:
		audio_server.set_bus_mute(bus_index, true)
	if Global.crt == true :
		effect.visible = true
	else:
		effect.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_button_pressed() -> void:
	pass


func _on_htp_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/htp.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settigs.tscn")
