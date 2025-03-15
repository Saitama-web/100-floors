extends Control


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

#var file_path = "user://savedata.tres"
var file_path = "res://savedata.tres"

func try_exit():
	$exit_window.show()

func update_player_base(level: int):
	g.base_hp = round(10 * level + pow(level, 2.074))
	g.base_atk = round(1 + 2.5 * (level-1) + pow((level-1), 1.46))
	g.base_def = round(1 + 1.5 * (level-1) + pow((level-1), 1.1))
	#print(str(level)+" , "+str(g.base_atk))

func update_global():
	if !g.player_level:
		g.player_level=1
	update_player_base(g.player_level)
	g.added_atk=0
	g.added_def=0
	g.added_hp=0
	for i in range(g.equipped.size()):
		if g.equipped[i][1]==g.item[0]:
			if g.equipped[i][0]==g.rarity[0]:
				g.added_atk+=g.base_atk*10
			if g.equipped[i][0]==g.rarity[1]:
				g.added_atk+=g.base_atk*5
			if g.equipped[i][0]==g.rarity[2]:
				g.added_atk+=g.base_atk*2
		elif g.equipped[i][1]==g.item[1]:
			if g.equipped[i][0]==g.rarity[0]:
				g.added_def+=g.base_def*10
			if g.equipped[i][0]==g.rarity[1]:
				g.added_def+=g.base_def*5
			if g.equipped[i][0]==g.rarity[2]:
				g.added_def+=g.base_def*2
		elif g.equipped[i][1]==g.item[2]:
			if g.equipped[i][0]==g.rarity[0]:
				g.added_hp+=g.base_hp*10
			if g.equipped[i][0]==g.rarity[1]:
				g.added_hp+=g.base_hp*5
			if g.equipped[i][0]==g.rarity[2]:
				g.added_hp+=g.base_hp*2

func _ready() -> void:
	$exit_window.hide()
	$save_hint.modulate.a = 0
	if !g.data_loaded:
		load_data()
		g.data_loaded=true
		update_global()
	#get_tree().root.connect("quit",try_exit)
	#get_tree().root.connect("go_back_requested",try_exit)
	#get_tree().quit_on_go_back = false
	g.last_scene="res://main.tscn"
	$coins/Panel/Label.text=str(g.total_gold)
	$Button2/Panel/Label.text=str(g.wish_count)
	if g.save:
		save()
		update_global()
		g.save=false
	anim.play("idle")
	if g.sound_on:
		$sound.text ="sound on"
	else:
		$sound.text ="sound off"

func _on_inv_pressed() -> void:
	g.last_scene="res://inventory.tscn"
	get_tree().change_scene_to_file("res://inventory.tscn")

func _on_bat_pressed() -> void:
	g.last_scene="res://floor.tscn"
	get_tree().change_scene_to_file("res://floor.tscn")

func _on_gat_pressed() -> void:
	g.last_scene="res://wishtree.tscn"
	get_tree().change_scene_to_file("res://wishtree.tscn")

func _on_sta_pressed() -> void:
	g.last_scene="res://statsviewer.tscn"
	get_tree().change_scene_to_file("res://statsviewer.tscn")

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://store.tscn")

func _on_coins_pressed() -> void:
	get_tree().change_scene_to_file("res://store.tscn")

func save_hint(word):
	#$save_hint.show()
	$save_hint.text = word
	var tween = create_tween()
	tween.tween_property($save_hint,"modulate:a",1,0.2).set_delay(0.2)
	tween.tween_property($save_hint,"modulate:a",0,0.5).set_delay(0.5)

func save():
	var file=saves.new()
	file.from_g()
	ResourceSaver.save(file,file_path)
	var error = ResourceSaver.save(file,file_path)
	if error==OK:
		save_hint("saved")
	else:
		save_hint("error saving")

func load_data():
	if FileAccess.file_exists(file_path):
		var save_data = ResourceLoader.load(file_path) as saves
		if save_data:
			save_data.to_g()
			save_hint("loaded")
		else:
			save_hint("error loading")
	else:
		save_hint("file not found")

func _on_cancel_pressed() -> void:
	$exit_window.hide()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_upgrade_pressed() -> void:
	get_tree().change_scene_to_file("res://upgrade.tscn")

func _on_sound_pressed() -> void:
	g.sound_on =!g.sound_on
	if g.sound_on:
		$sound.text ="sound on"
	else:
		$sound.text ="sound off"
		 
