extends Control

#region New Code Region
@onready var label: Label = $Panel/Control/Label
var atk
var def
var hp
#endregion

func _ready() -> void:
	#get_tree().root.connect("go_back_requested",_on_back_pressed)
	#get_tree().quit_on_go_back = false
	update_label()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func update_label():
	atk=g.base_atk+g.added_atk
	def=g.base_def+g.added_def
	hp=g.base_hp+g.added_hp
	$Panel/Control/Label.text="atk : "+str(atk)+"\ndef : "+str(def)+"\nhp : "+str(hp)
