extends Control

#region New Code Region
const player_ = preload("res://player.tscn")
const dummy_ = preload("res://dummy.tscn")
const chest_ = preload("res://chest.tscn")

var total_enemy = []
var remaining_enemy = 0
var enemy_killed = 0  #wave
var total_enemy_killed = 0 #floor
var wave_cd = 2
var enemy_spawned = 0
var can_begin_wave =false
var wave_counter = 0
var wave_cleared = false
var player
var current_camera_pos=0
var total_enemy_count = 0
#var boss_level =false
var floor_cleared = false
var def_scale_label
var can_coin_animate = true
var cam_pos = [570,1650]
var camera_in_boss_area = false
var once_=false
var can_spawn_wave = true
#endregion

func _ready() -> void:
	#get_tree().root.connect("go_back_requested",_on_back_pressed)
	#get_tree().quit_on_go_back = false
	randomize()
	spawn_player()
	start_floor()
	$Camera2D.global_position.x = 570
	$CanvasLayer2/popup.hide()
	$CanvasLayer2/back.show()
	$CanvasLayer2/coins/Panel/Label.text=str(g.total_gold)
	def_scale_label=$CanvasLayer2/coins/Panel/Label.scale
	$CanvasLayer2/Panel/Label.text = "Floor "+str(g.current_floor)
	camera_in_boss_area=false

func on_coin_anim_finished():
	can_coin_animate=true

func coin_anim():
	$CanvasLayer2/coins/Panel/Label.text=str(g.total_gold)
	if can_coin_animate:
		can_coin_animate=false
		var tween = create_tween().parallel()
		tween.tween_property($CanvasLayer2/coins/Panel/Label,"scale:y",def_scale_label.y*1.2,0.1)
		tween.tween_property($CanvasLayer2/coins/Panel/Label,"scale:y",def_scale_label.y*1,0.1).set_delay(0.1)
		#tween.tween_property($CanvasLayer2/coins/Panel/Label,"scale:x",def_scale_label.x*1.5,0.1)
		#tween.tween_property($CanvasLayer2/coins/Panel/Label,"scale:x",def_scale_label.x*1,0.1).set_delay(0.1)
		tween.finished.connect(on_coin_anim_finished)
	#return "coin"

func count_enemy(array):
	var add = 0
	for i in array:
		add += i[0]
	return add
	print(add)

func push_player():
	player.init_push()

#func create_enemy_pattern():
	#var enemy_patern = []
	#for i in range(randi_range(1,3)):
		#enemy_patern.append(randi_range(2,5))
	#
	#print(enemy_patern)
	#return enemy_patern

var is_mini_boss = false
var is_main_boss = false
var is_super_boss = false

func create_enemy_pattern(level: int) -> Array:
	var enemy_pattern = []
	var max_waves = min(2 + level / 20, 5)  # Gradual wave increase up to 5

	# Normal enemy waves (Low count, high level)
	for wave_index in range(max_waves):
		var enemy_level = clamp(wave_index + (level / 2), 1, 100)
		var enemies_in_wave = 2 + int(level / 30)  # Low count, high level
		enemy_pattern.append([enemies_in_wave, enemy_level])  # [count, level]

	# Handle boss logic globally
	is_mini_boss = level % 10 in [3, 6]
	is_main_boss = level % 10 == 0
	is_super_boss = level >= 90 and level % 10 == 0

	return enemy_pattern

func start_floor():
	$CanvasLayer2/Panel/Label.text = "Floor "+str(g.current_floor)
	wave_counter=-1
	wave_cleared=false
	player.position = Vector2i(0,295) #y=295
	push_player()
	#once = false
	total_enemy=create_enemy_pattern(g.current_floor)
	#if g.current_floor==10 or g.current_floor==20 or g.current_floor==30:
		#boss_level=true
	#else:
		#boss_level=false
	total_enemy_count=count_enemy(total_enemy)
	if $StaticBody2D/wave_barrier.disabled:
		$StaticBody2D/wave_barrier.disabled=false

func _process(delta: float) -> void:
	if floor_cleared:
		if !once_:
			once_ = true
			if is_mini_boss or is_main_boss or is_super_boss:
				if !$StaticBody2D/wave_barrier.disabled:
					$StaticBody2D/wave_barrier.disabled=true
				if !camera_in_boss_area:
					if player.global_position.x>=1100:
						#camera_in_boss_area=true
						var tween = get_tree().create_tween()
						tween.tween_property($Camera2D,"position:x",cam_pos[1],0.5)
						if tween.finished:
							camera_in_boss_area=true
				else:
					if player.global_position.x<1100:
						var tween = get_tree().create_tween()
						tween.tween_property($Camera2D,"position:x",cam_pos[0],0.5)
						camera_in_boss_area=false
			else:
				spawn_chest()
				$CanvasLayer2/popup.show()
				$CanvasLayer2/back.hide()
				$CanvasLayer2/popup/Label.text="Level Cleared"
				$CanvasLayer2/popup/next.text="Next"
	else:
		if total_enemy_killed==total_enemy_count:
			floor_cleared=true
			if once_:
				once_=false
		elif enemy_spawned!= total_enemy_count:
			spawn_enemies(total_enemy)

func spawn_enemies(spawn_order):
	if  player.ready_:
		if !wave_cleared:
			if wave_counter== -1:
				can_begin_wave = true
			elif enemy_killed==spawn_order[wave_counter][0]:
				can_spawn_wave=true
				wave_cleared=true
				$wave_cd.start(1)

		if can_begin_wave:
			can_begin_wave=false
			wave_counter +=1
			wave_cleared=false
			spawn_dummy(spawn_order[wave_counter])
			enemy_killed=0

func spawn_chest():
	var chest = chest_.instantiate()
	chest.global_position.y=0 #player.global_position.y-100
	chest.global_position.x = player.global_position.x+100
	add_child(chest)

func spawn_player():
	var a = player_.instantiate()
	#a.position = $Marker2D.position
	player = a
	$spawns.add_child(a)
	g.player=player

func spawn_dummy(enemy_data):
	enemy_spawned+=enemy_data[0]
	for i in range(enemy_data[0]):
		var a = dummy_.instantiate()
		a.level = enemy_data[1]
		a.position = Vector2i(randi_range(0,1150),0)
		$spawns.add_child(a)
		await get_tree().create_timer(0.5).timeout

func update_floor():
	floor_cleared=false
	g.current_floor+=1
	#g.player = null
	enemy_killed=0
	total_enemy_killed=0
	enemy_spawned=0
	$Camera2D.global_position.x = 570
	$CanvasLayer2/popup.hide()
	$CanvasLayer2/back.show()
	start_floor()

func _on_button_pressed() -> void:
	spawn_dummy(1)

func _on_wave_cd_timeout() -> void:
	can_begin_wave=true

func _on_menu_pressed() -> void:
	g.current_floor+=1
	g.save=true
	get_tree().change_scene_to_file("res://main.tscn")

func _on_next_pressed() -> void:
	update_floor()

func _on_back_pressed() -> void:
	g.save = true
	get_tree().change_scene_to_file("res://main.tscn")
