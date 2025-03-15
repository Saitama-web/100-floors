extends Control

func _ready() -> void:
	#get_tree().root.connect("go_back_requested",_on_back_pressed)
	#get_tree().quit_on_go_back = false
	update_label()
	update_label2()
	$level.text = "Level "+str(g.player_level)
	$AnimatedSprite2D.play("idle")

func _on_back_pressed() -> void:
	g.save=true
	get_tree().change_scene_to_file("res://main.tscn")

func _on_upgrade_pressed() -> void:
	g.player_level+=1
	$level.text = "Level "+str(g.player_level)
	update_label()
	update_label2()

func base(level):
	var data = []
	var hp = roundi(10 * level + pow(level, 2.074))
	var atk = roundi(1 + 2.5 * (level-1) + pow((level-1), 1.46))
	var def = roundi(1 + 1.5 * (level-1) + pow((level-1), 1.1))
	data.append(atk)
	data.append(def)
	data.append(hp)
	return data

func update_label():
	var data = base(g.player_level)
	$Panel/Label.text="atk : "+str(data[0])+"\ndef : "+str(data[1])+"\nhp : "+str(data[2])

func update_label2():
	var data = base(g.player_level+1)
	$Panel/Label2.text="--> "+str(data[0])+"\n--> "+str(data[1])+"\n--> "+str(data[2])
