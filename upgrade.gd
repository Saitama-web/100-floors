extends Control

func _ready() -> void:
	get_tree().root.connect("go_back_requested",_on_back_pressed)
	get_tree().quit_on_go_back = false

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://statsviewer.tscn")
