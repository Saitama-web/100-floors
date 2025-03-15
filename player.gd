extends CharacterBody2D

#region New Code Region
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var bar_pos: Node2D = $bar_position
@onready var bar: ProgressBar = $CanvasLayer/hp_bar
const dmg_num = preload("res://characters/dmg_num.tscn")
var na = ["atk1","atk2"]
var sound=[
preload("res://assets/sprites/sword-sound-effect-1-234987.mp3"),
preload("res://assets/sprites/sword-sound-effect-2-234986.mp3"),
preload("res://assets/sprites/sword-stab-pull-melee-weapon-236207.mp3"),
preload("res://assets/sprites/blank3.mp3")
]
var enemies =[]
var normal_dmg = 1
var total_dmg:int
var skill_dmg :int
var burst_dmg :int
var won=false
var lost= false
var total_def:int
var skill_cd = 5.0
var burst_cd = 10.0
var max_hp : int
var hp : int
var def:int
var attacking = false
var constant = 0.2
var can_skill = true
var can_burst = true
var facing_right = true
var speed = 200
var moving = false
var dash_cd = 2.0
var dashing = false
var can_dash = true
var chest = null
var push = false
var crit_rate = 20
var critical_hit = false
var ready_=false
var impact_pause = 0.2+0.15
var can_stop = true

var base_hp = 0
var base_atk = 0
var base_def = 0

#endregion

func _ready() -> void:
	#if g.sound_on:
		#$AudioStreamPlayer2D.stream_paused=false
	#else:
		#$AudioStreamPlayer2D.stream_paused=true
	max_hp = g.base_hp+g.added_hp
	hp=max_hp
	def=g.base_def+g.added_def
	total_def=def
	normal_dmg=g.base_atk+g.added_atk
	total_dmg=normal_dmg
	skill_dmg=normal_dmg*2
	burst_dmg=normal_dmg*5
	add_to_group("player")
	if bar.has_theme_stylebox_override("fill"):
		bar.remove_theme_stylebox_override("fill")
		var a = StyleBoxFlat.new()
		bar.add_theme_stylebox_override("fill",a)
		a.bg_color=bar.p_color
		a.corner_detail=8
		a.border_width_bottom=5
		a.border_width_top=5
		a.border_width_left=5
		a.border_width_right=0
		a.border_color=Color(0,0,0,1)
		a.border_blend=false
		a.corner_radius_bottom_left=5
		a.corner_radius_bottom_right=5
		a.corner_radius_top_left=5
		a.corner_radius_top_right=5
		a.anti_aliasing=false
	bar.max_value=hp
	bar.value=bar.max_value
	bar.position.x += bar.size.x/2*scale.x
	
	z_index=0
	$CanvasLayer/buttons/skill/time.hide()
	$CanvasLayer/buttons/burst/time.hide()
	$CanvasLayer/buttons/dash/time.hide()
	$CanvasLayer/buttons/skill/TextureProgressBar.max_value = skill_cd
	$CanvasLayer/buttons/burst/TextureProgressBar.max_value = burst_cd
	$CanvasLayer/buttons/dash/TextureProgressBar.max_value = dash_cd
	$CanvasLayer/buttons/attack/TextureProgressBar.max_value = 10.0
	$CanvasLayer/buttons/attack/TextureProgressBar.value = 0
	$CanvasLayer/buttons/skill/TextureProgressBar.value = 0
	$CanvasLayer/buttons/burst/TextureProgressBar.value = 0
	$CanvasLayer/buttons/dash/TextureProgressBar.value = 0

func attack():
	var dmg = 0
	if Input.is_action_just_pressed("normal"):
		if !attacking:
			critical_hit=false
			if facing_right:
				velocity.x = 200
			else:
				velocity.x = -200
			var tween = get_tree().create_tween()
			tween.tween_property(self,"velocity:x",0,0.2)
			anim.play(na.pick_random())
			dmg = total_dmg
			attacking=true
			$attack_duration.start(0.4)
			if !enemies.is_empty():
				if randi_range(0,100)<crit_rate:
					dmg = dmg*2
					critical_hit=true
				await get_tree().create_timer(0.1).timeout 
				$Node2D/flash.play("flash")
				for enemy in enemies:
					enemy.hit(dmg)
			elif chest:
				await get_tree().create_timer(0.1).timeout
				chest.open()
			else:
				if g.sound_on:
					$AudioStreamPlayer2D.stream=sound[3]
					$AudioStreamPlayer2D.volume_db = -1
					$AudioStreamPlayer2D.play()
	elif Input.is_action_just_pressed("skill"):
		if can_skill:
			critical_hit=false
			$CanvasLayer/buttons/skill/time.show()
			$CanvasLayer/buttons/skill/TextureProgressBar.value=skill_cd
			$skill_timer.start(skill_cd)
			can_skill=false
			anim.play("atk3")
			dmg = skill_dmg
			attacking=true
			$attack_duration.start(0.75)
			if !enemies.is_empty():
				if randi_range(0,100)<crit_rate:
					dmg = dmg*2
					critical_hit=true
				await get_tree().create_timer(0.1).timeout
				$Node2D/flash.play("flash")
				for enemy in enemies:
					enemy.hit(dmg)
			else:
				if g.sound_on:
					$AudioStreamPlayer2D.stream=sound[3]
					$AudioStreamPlayer2D.volume_db = -1
					$AudioStreamPlayer2D.play()
	elif Input.is_action_just_pressed("burst"):
		if can_burst:
			critical_hit=false
			$CanvasLayer/buttons/burst/time.show()
			$CanvasLayer/buttons/burst/TextureProgressBar.value=burst_cd
			$burst_timer.start(burst_cd)
			can_burst=false
			anim.play("atk4")
			dmg = burst_dmg
			attacking=true
			$attack_duration.start(0.4)
			if !enemies.is_empty():
				if randi_range(0,100)<crit_rate:
					dmg = dmg*2
					critical_hit=true
				await get_tree().create_timer(0.1).timeout
				$Node2D/flash.play("flash")
				for enemy in enemies:
					enemy.hit(dmg)
			else:
				if g.sound_on:
					$AudioStreamPlayer2D.stream=sound[3]
					$AudioStreamPlayer2D.volume_db = -1
					$AudioStreamPlayer2D.play()

func _on_unpauser_timeout() -> void:
	get_tree().paused=false
	can_stop=true
	critical_hit=false

func movement():
	if Input.is_action_just_pressed("dash") and !dashing and can_dash:
		$CanvasLayer/buttons/dash/TextureProgressBar.value=dash_cd
		$CanvasLayer/buttons/dash/time.show()
		dashing = true
		can_dash=false
		$dash_cd.start(dash_cd)
		if facing_right:
			velocity.x = 800
		else:
			velocity.x = -800
		var tween = get_tree().create_tween()
		tween.tween_property(self,"velocity:x",0,0.5).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(end_dashing)
	elif Input.is_action_pressed("left") and !dashing:
		if facing_right:
			flip()
			facing_right = false
		velocity.x = -speed
		moving = true
		anim.play("walk")
	elif Input.is_action_pressed("right") and !dashing:
		if !facing_right:
			flip()
			facing_right=true
		velocity.x = speed
		moving = true
		anim.play("walk")
	elif !dashing:
		velocity.x=0
		moving = false

func end_dashing():
	dashing=false

func init_push():
	push = true
	velocity.x = 1000
	ready_=false
	if !facing_right:
		flip()
		facing_right = true

func set_push():
	push = false
	ready_=true

func update_icon():
	if !can_skill:
		$CanvasLayer/buttons/skill/time.text=str(snapped($skill_timer.time_left,0.1))
		$CanvasLayer/buttons/skill/TextureProgressBar.value = snapped($skill_timer.time_left,0.01)
	if !can_burst:
		$CanvasLayer/buttons/burst/time.text=str(snapped($burst_timer.time_left,0.1))
		$CanvasLayer/buttons/burst/TextureProgressBar.value = snapped($burst_timer.time_left,0.01)
	if !can_dash:
		$CanvasLayer/buttons/dash/time.text=str(snapped($dash_cd.time_left,0.1))
		$CanvasLayer/buttons/dash/TextureProgressBar.value = snapped($dash_cd.time_left,0.01)

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += get_gravity().y *5 * delta
	if push:
		var tween = get_tree().create_tween()
		tween.tween_property(self,"velocity:x",0,0.5).set_ease(Tween.EASE_IN)
		tween.tween_callback(set_push)
	if !push:
		attack()
		if !attacking:
			movement()
	move_and_slide()
	update_icon()
	if !attacking and !moving:
		anim.play("idle")

func defence_dmg_filter(dmg):
	# Calculate damage reduction
	var dmg_red = total_def * constant / (1 + total_def * constant)
	dmg_red = clamp(dmg_red, 0.0, 1.0)  # Clamp between 0% and 100%
	
	# Apply damage reduction
	dmg = ceili(max(dmg - dmg * dmg_red,0))
	return dmg

func hit(raw_dmg):
	var dmg = defence_dmg_filter(raw_dmg)
	if dmg<=0:
		return
	hp-=dmg
	if hp<=0:
		if g.sound_on:
			$AudioStreamPlayer2D.stream=sound[2]
			$AudioStreamPlayer2D.play()
		handle_lost()
	else:
		if g.sound_on:
			$AudioStreamPlayer2D.stream=sound[randi_range(0,1)]
			$AudioStreamPlayer2D.play()
	
	var dmg_indicator = dmg_num.instantiate()
	dmg_indicator.text=str(dmg)
	bar_pos.add_child(dmg_indicator)
	bar.value-=dmg

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		enemies.append(body)
	if body.is_in_group("chest"):
		chest = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if enemies.has(body):
		enemies.erase(body)
	if chest == body:
		chest = null

func reset_atk_timer():
	$attack_timer.stop()
	$skill_timer.stop()
	$burst_timer.stop()
	can_skill=true
	can_burst=true

func handle_lost():
	get_parent().get_parent().choice_panel.show()
	hide()
	get_tree().paused=true

func reset_hp():
	hp = g.base_hp+g.added_hp
	bar.value=bar.max_value

func _on_attack_duration_timeout() -> void:
	attacking=false

func flip():
	anim.flip_h =!anim.flip_h
	$Area2D.rotate(PI)
	$Node2D.rotate(PI)

func _on_skill_timer_timeout() -> void:
	can_skill = true
	$CanvasLayer/buttons/skill/time.hide()
	$CanvasLayer/buttons/skill/TextureProgressBar.value = 0

func _on_burst_timer_timeout() -> void:
	can_burst = true
	$CanvasLayer/buttons/burst/time.hide()
	$CanvasLayer/buttons/burst/TextureProgressBar.value = 0

func _on_dash_cd_timeout() -> void:
	can_dash=true
	$CanvasLayer/buttons/dash/time.hide()
	$CanvasLayer/buttons/dash/TextureProgressBar.value = 0

func _on_attack_pressed() -> void:
	Input.action_press("normal")
	await get_tree().create_timer(0.1).timeout
	Input.action_release("normal")

func _on_skill_pressed() -> void:
	Input.action_press("skill")
	await get_tree().create_timer(0.1).timeout
	Input.action_release("skill")

func _on_burst_pressed() -> void:
	Input.action_press("burst")
	await get_tree().create_timer(0.1).timeout
	Input.action_release("burst")

func _on_dash_pressed() -> void:
	Input.action_press("dash")
	await get_tree().create_timer(0.1).timeout
	Input.action_release("dash")

var down = false
func _on_left_button_down() -> void:
	if !down:
		down = true
		Input.action_press("left")

func _on_left_button_up() -> void:
	Input.action_release("left")
	down=false

func _on_right_button_down() -> void:
	if !down:
		down = true
		Input.action_press("right")

func _on_right_button_up() -> void:
	Input.action_release("right")
	down=false

func _on_delay_timeout() -> void:
	get_tree().paused=true
