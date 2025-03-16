extends Control

#region New Code Region
const inv_item = preload("res://inv_item.tscn")
var equ_rect
var inv_rect
var click_pos:Vector2
var mouse_pos:Vector2
var item
var clicked=false
var aclicked=false
var clicked_item_count:int = -1
var inv_limit=g.inv_capacity
var equ_limit=3
var items_total=[]
var offset:Vector2
var temp_texture : Texture2D
var icon
var done=false
@onready var inv: VBoxContainer = $inv/Container/VBoxContainer
@onready var equ: Node2D = $equ/container
var clicked_item_pos = -1
var weapon_equipped = false
var artifact_equipped = false
var armour_equipped = false
var equipped_item_pos = -1
var armour_pos = Vector2(256,176)
var weapon_pos = Vector2(256,368)
var artifact_pos = Vector2(96,272)

#endregion

func update_label2():
	if g.bag.size()<=0:
		$inv/Label.show()
	else:
		$inv/Label.hide()

func _ready() -> void:
	$item_stats/Label/remove.hide()
	$item_stats/Panel.hide()
	#get_tree().root.connect("go_back_requested",_on_back_pressed)
	#get_tree().quit_on_go_back = false
	$item_stats.hide()
	items_total=[g.swords,g.armours,g.artifacts]
	update_inventory()
	update_equipped()
	
	call_deferred("set_rect")
	update_label2()

func set_rect():
	equ_rect = Rect2($equ.global_position,$equ.size)
	inv_rect = Rect2($inv.global_position,$inv.size)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		clicked_item_count=-1
		click_pos=get_global_mouse_position()
		if inv_rect.has_point(click_pos):
			$item_stats/Label/remove.hide()
			var breaked= false
			for child in inv.get_children():
				for child2 in child.get_children():
					clicked_item_count+=1
					if child2.clicked:
						if $item_stats/Control/equip.disabled:
							$item_stats/Control/equip.disabled=false
						if $item_stats/Control/enhance.disabled:
							$item_stats/Control/enhance.disabled=false
						clicked_item_pos=clicked_item_count
						clicked=true
						update_label(child2.details)
						breaked=true
						break
					#else:
						#$item_stats.hide()
				if breaked:
					break

		elif equ_rect.has_point(click_pos):
			if $item_stats/Control/equip.disabled==false:
				$item_stats/Control/equip.disabled = true
			for child in equ.get_children():
				clicked_item_count+=1
				if child.clicked:
					equipped_item_pos=clicked_item_count
					update_label(child.details)
					$item_stats/Label/remove.show()
					if $item_stats/Control/enhance.disabled:
						$item_stats/Control/enhance.disabled=false
					break
				#else:
					#$item_stats.hide()
		else:
			if!button_pressed:
				$item_stats.hide()
				#$item_stats/Control/equip.disabled=true
				#$item_stats/Control/enhance.disabled=true
				#$item_stats/Label/remove.hide()

	elif Input.is_action_just_released("click"):
		button_pressed=false

func _on_back_pressed() -> void:
	g.save=true
	get_tree().change_scene_to_file("res://main.tscn")

func update_inventory1():
	if inv.get_child_count()>0:
		for ch in inv.get_children():
			ch.queue_free()

func update_inventory():
	if g.bag.size()>0:
		$inv/Label.hide()
		var hcon 
		var hbox_init = false
		for i in range(0,g.bag.size()):
			var items = inv_item.instantiate()
			items.details=g.bag[i]
			var can_break = false
			for k in range(0,3):
				for j in range(0,3):
					if items.details[1]==g.item[k] and items.details[0]==g.rarity[j]:
						items.icon=items_total[k][j]
						can_break=true
						break
				if can_break:
					break
			
			if i%4==0 or !hbox_init:
				hbox_init=true
				hcon = HBoxContainer.new()
				hcon.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				hcon.size_flags_vertical=Control.SIZE_FILL
				if hbox_init:
					inv.add_child(hcon)
			hcon.add_child(items)
	else:
		$inv/Label.show()

func update_equipped1():
	if equ.get_child_count()>0:
		for ch in equ.get_children():
			ch.queue_free()

func update_equipped():
	if g.equipped.size()>0:
		for i in range(0,g.equipped.size()):
			var items = inv_item.instantiate()
			items.details= g.equipped[i]
			var can_break = false
			for k in range(0,3):
				for j in range(0,3):
					if items.details[1]==g.item[k] and items.details[0]==g.rarity[j]:
						if k==0 :
							items.position = weapon_pos
						elif k == 1 :
							items.position = armour_pos
						elif k == 2 :
							items.position = artifact_pos
						items.icon=items_total[k][j]
						can_break=true
						break
				if can_break:
					break
				
			equ.add_child(items)

func update_label(vec:Array):
	$item_stats.show()
	$item_stats/Label.text="\t"+vec[0]+" "+vec[1]+"\nLevel: "+str(vec[2])+"\n\nEffects:\n "
	var amount
	var b
	if vec[0]=="Legendary":
		amount=10
	elif vec[0]=="Rare":
		amount=5
	elif vec[0]=="Dull":
		amount=2
		
	if vec[1]=="Sword":
		b="ATK"
	elif vec[1]=="Armour":
		b="DEF"
	elif vec[1]=="Artifact":
		b="HP"
	$item_stats/Label.text+="Increases "+b+" "+str(amount)+"x"

var conf_clicked_item_pos =-1
func _on_equip_pressed() -> void:
	if clicked_item_pos<0:
		return
	for i in g.equipped.size():
		if g.equipped[i][1] == g.bag[clicked_item_pos][1]:
			conf_clicked_item_pos=i
			$item_stats/Panel.show()
			get_tree().paused=true
			return
	g.equipped.append(g.bag.pop_at(clicked_item_pos))
	
	update_inventory1()
	update_equipped1()
	update_inventory()
	update_equipped()
	$item_stats/Control/equip.disabled=true
	$item_stats/Control/enhance.disabled=true
	$item_stats/Label/remove.hide()

var button_pressed = false
func _on_equip_button_down() -> void:
	button_pressed=true

var ok = false
func _on_enhance_button_down() -> void:
	button_pressed=true

func _on_ok_pressed() -> void:
	get_tree().paused=false
	ok = true
	g.bag.append(g.equipped.pop_at(conf_clicked_item_pos))
	g.equipped.append(g.bag.pop_at(clicked_item_pos))
	
	update_inventory1()
	update_equipped1()
	update_inventory()
	update_equipped()
	$item_stats/Panel.hide()
	$item_stats/Control/equip.disabled=true
	$item_stats/Control/enhance.disabled=true
	$item_stats/Label/remove.hide()

func _on_cancel_pressed() -> void:
	get_tree().paused=false
	ok = false
	$item_stats/Panel.hide()
	$item_stats/Control/equip.disabled=true
	$item_stats/Control/enhance.disabled=true
	$item_stats/Label/remove.hide()

func _on_remove_pressed() -> void:
	if equipped_item_pos<0:
		return
	g.bag.append(g.equipped.pop_at(equipped_item_pos))
	update_inventory1()
	update_equipped1()
	update_inventory()
	update_equipped()
	$item_stats/Control/equip.disabled=true
	$item_stats/Control/enhance.disabled=true
	$item_stats/Label/remove.hide()

func _on_remove_button_down() -> void:
	button_pressed=true
