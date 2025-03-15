extends Control

#region New Code Region
var biased_rand=[2,2,2,2,2,2,2,1,1,0]
var pulls=10
var items_total =[]
var items_textures =[]
@onready var vbox: VBoxContainer = $prev/VBoxContainer
#endregion

func _ready() -> void:
	#get_tree().root.connect("go_back_requested",_on_back_pressed)
	#get_tree().quit_on_go_back = false
	items_total=[g.swords,g.armours,g.artifacts]
	$prev/wish_animation.hide()
	$prev/Label.hide()
	randomize()
	update_wish_count()
	$Label.hide()

func _on_back_pressed() -> void:
	g.save=true
	get_tree().change_scene_to_file("res://main.tscn")

func _on_button_pressed() -> void:
	hide_pulls()
	if g.wish_count>0:
		create_item(1)
	else:
		$Label.show()
		$"Label/error print timer".start(2)

func create_item(num):
	var aquired=[]
	var rand_rarity = g.rarity[biased_rand.pick_random()]
	var rand_item = g.item.pick_random()
	aquired.append(rand_rarity)
	aquired.append(rand_item)
	aquired.append(1)
	
	if g.bag.size()<g.inv_capacity:
		g.wish_count-=1
		g.bag.append(aquired)
		if num==1:
			$prev/wish_animation.show()
			$prev/Label.show()
		var can_break=false
		for k in range(0,3):
			for j in range(0,3):
				if aquired[1]==g.item[k] and aquired[0]==g.rarity[j]:
					if num==1:
						$prev/wish_animation.texture=items_total[k][j]
						$prev/wish_animation.scale=Vector2(5,5)
						$prev/Label.text=rand_rarity+" "+rand_item
						can_break=true
						break
					else:
						var img = TextureRect.new()
						#img.size=Vector2(500,500)
						img.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT
						img.texture=items_total[k][j]
						items_textures.append(img)
						can_break=true
						break
			if can_break:
				break

		update_wish_count()
	else:
		print("inventory full")
	
func update_wish_count():
	$Button2/Panel/Label.text=str(g.wish_count)

func _on_error_print_timer_timeout() -> void:
	$Label.hide()

func _on_button_2_pressed() -> void:
	g.last_scene="res://wishtree.tscn"
	get_tree().change_scene_to_file("res://store.tscn")

func _on_pulls_pressed() -> void:
	hide_pulls()
	if g.wish_count>=pulls:
		for i in range(pulls):
			create_item(pulls)
		var hbox_init = false
		var hcon
		vbox.scale=Vector2(1,1)*2.8
		for i in range(items_textures.size()):
			if i%5==0 or !hbox_init:
				hbox_init=true
				hcon = HBoxContainer.new()
				hcon.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				hcon.size_flags_vertical=Control.SIZE_FILL
				if hbox_init:
					vbox.add_child(hcon)
			var a=items_textures[i]
			if hcon:
				hcon.add_child(a)
	else:
		if ! $Label.visible:
			$Label.show()
			$"Label/error print timer".start(2)

func hide_pulls():
	if vbox.get_child_count()>0:
		for c in vbox.get_children():
			vbox.remove_child(c)
	$prev/wish_animation.visible = false
	$prev/Label.hide()
