extends Node2D
@onready var effect: CanvasLayer = $effect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.crt == true :
		effect.visible = true
	else:
		effect.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start screen.tscn")
