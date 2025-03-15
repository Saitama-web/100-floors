extends Control

#region New Code Region
@onready var label: Label = $Panel/Control/Label
var final_atk
var final_def
var final_hp
#endregion

func _ready() -> void:
	#get_tree().root.connect("go_back_requested",_on_back_pressed)
	#get_tree().quit_on_go_back = false
	update_label()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func update_label():
	final_atk=g.base_atk+g.added_atk
	final_def=g.base_def+g.added_def
	final_hp=g.base_hp+g.added_hp
	label.text="atk : "+str(final_atk)+"\ndef : "+str(final_def)+"\nhp : "+str(final_hp)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://upgrade.tscn")
