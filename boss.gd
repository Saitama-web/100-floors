extends CharacterBody2D

#region New Code Region
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio= AudioStreamPlayer2D.new()
const p_bar = preload("res://p_bar.tscn")
const dmg_num = preload("res://characters/dmg_num.tscn")
const drop = preload("res://drop.tscn")
var sound=[
preload("res://assets/sprites/sword-sound-effect-1-234987.mp3"),
preload("res://assets/sprites/sword-sound-effect-2-234986.mp3"),
preload("res://assets/sprites/sword-stab-pull-melee-weapon-236207.mp3"),
preload("res://assets/sprites/blank3.mp3"),
preload("res://assets/sounds/summon.mp3")
]
var max_atk = 0
var atk = 1
var max_hp = 5
var hp = 0
var max_def = 0
var def = 0
var attacking = false
var bar = p_bar.instantiate()
var z_index_options = [1]
var hurt = false
var hurt_duration = 1
var speed = 100
var atk_cd = 2.0
var boss_level : int
var can_attack = false
var facing_right = false
var can_move = false
var atk_in_cd = false
var type : String
#endregion

func set_enemy_stats(level: int):
	# Mini Boss at 3, 13, 23... and 6, 16, 26...
	#if g.current_floor % 10 in [3, 6] and g.current_floor!=0:
	if type=="mini":
		boss_level = roundi(clamp(min(2 + level / 20.0, 5) + (level / 2.0), 1, 100)*1.2)
		max_hp = round(boss_level * 20 + pow(boss_level, 2.4))
		max_atk = round(boss_level * 4 + pow(boss_level, 1.5))
		max_def = round(boss_level * 2 + pow(boss_level, 1.3))
		$CollisionShape2D.scale *= 1.5
		$AnimatedSprite2D.scale *= 1.5
	# Main Boss at 10, 20, 30...
	#elif g.current_floor % 10 == 0 and g.current_floor!=0:
	if type=="main":
		boss_level = roundi(clamp(min(2 + level / 20.0, 5) + (level / 2.0), 1, 100)*1.5)
		max_hp = round(boss_level * 40 + pow(boss_level, 2.6))
		max_atk = round(boss_level * 6 + pow(boss_level, 1.7))
		max_def = round(boss_level * 3 + pow(boss_level, 1.5))
		$CollisionShape2D.scale *= 2
		$AnimatedSprite2D.scale *= 2

	# Super Boss from 90+ and every 10 floors
	#elif g.current_floor >= 90 and g.current_floor % 10 == 0 and g.current_floor!=0:
	if type=="super":
		boss_level = roundi(clamp(min(2 + level / 20.0, 5) + (level / 2.0), 1, 100)*2)
		max_hp = round(boss_level * 100 + pow(boss_level, 3))
		max_atk = round(boss_level * 10 + pow(boss_level, 2))
		max_def = round(boss_level * 5 + pow(boss_level, 1.8))
		$CollisionShape2D.scale *= 2.5
		$AnimatedSprite2D.scale *= 2.5

func attack():
	var dmg = 0
	if !attacking:
		anim.play("atk1")
		dmg = max_atk
		attacking=true
		$attack_duration.start(0.4)
		await get_tree().create_timer(0.2).timeout
		g.player.hit(dmg)

func move():
	if facing_right:
		velocity.x = speed
	else:
		velocity.x = -speed
	anim.play("walk")

var move_to_atk = true

func _ready() -> void:
	add_to_group("enemy")
	set_enemy_stats(g.current_floor)
	$CollisionShape2D/Label.text="Lv. "+str(boss_level)
	atk = max_atk
	def = max_def
	hp = max_hp
	print("hp : "+str(max_hp))
	bar.max_value = max_hp
	bar.value = hp
	if type == "mini":
		bar.for_mini =true
	elif type == "main":
		bar.for_main =true
	else:
		bar.for_super = true
	bar.for_enemy = true
	add_child(bar)
	get_parent().add_child.call_deferred(audio) #bug
	audio.process_mode=Node.PROCESS_MODE_ALWAYS
	z_index=z_index_options.pick_random()
	
	#if g.sound_on:
		#audio.stream_paused=false
	#else:
		#audio.stream_paused=true
	if g.sound_on:
		audio.stream=sound[4]
		audio.play()
	facing_right=false
	flip()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta *4
		velocity.x = 0
		anim.play("idle")
	if !hurt:
		if g.player.global_position.x>global_position.x:
			if !facing_right:
				flip()
				facing_right = true
		elif g.player.global_position.x<global_position.x:
			if facing_right:
				flip()
				facing_right = false
			
		if abs(g.player.global_position.x-global_position.x)>(100+(($CollisionShape2D.scale.x*27)-27)):
			can_move = true
			if !move_to_atk:
				move_to_atk=true
			move()
		elif !atk_in_cd and !can_move:
			if move_to_atk:
				$atk_cd.start(atk_cd/2)
				move_to_atk=false
				atk_in_cd=true
			else:
				atk_in_cd=true
				$atk_cd.start(atk_cd)
				velocity.x = 0
				can_move = false
				can_attack=true
				attack()
		else:
			if !attacking:
				can_move=false
				can_attack=false
				velocity.x = 0
				anim.play("idle")
	else:
		if can_hurt:
			anim.play("hurt")
			if once:
				once = false
				anim.animation_finished.connect(can_hurt_)
		else:
			anim.play("idle")
			
	
	move_and_slide()

var once = true

func can_hurt_():
	once = true
	can_hurt=false

var can_hurt = true

func hit(dmg):
	$hurt_timer.stop()
	hurt = true
	can_hurt=true
	$hurt_timer.start(hurt_duration)
	if g.player:
		if g.player.global_position.x>global_position.x:
			velocity.x=-100
		elif g.player.global_position.x<global_position.x:
			velocity.x = 100
		var tween = get_tree().create_tween()
		tween.tween_property(self,"velocity:x",0,0.5)
	hp = max(0,hp-dmg)
	var dmg_indicator = dmg_num.instantiate()
	dmg_indicator.text=str(dmg)
	dmg_indicator.position.y -= 50
	add_child(dmg_indicator)

	if hp==0:
		dmg_indicator.reparent(get_parent().get_parent())
		if g.sound_on:
			audio.stream = sound[2]
			audio.play()
		despawn()
	else:
		bar.value = hp
		if g.sound_on:
			audio.stream = sound[randi_range(0,1)]
			audio.play()

func despawn():
	spawn_coin()
	get_parent().get_parent().boss_killed = true
	#get_parent().get_parent().enemy_killed +=1
	#get_parent().get_parent().total_enemy_killed +=1
	queue_free()

func flip():
	anim.flip_h =!anim.flip_h

func spawn_coin():
	for i in range(randi_range(0,5)):
		var a = drop.instantiate()
		a.position=position
		a.type="coin"
		get_parent().add_child(a)

func spawn_wish():
		var a = drop.instantiate()
		a.position=position
		a.type="wish"
		get_parent().add_child(a)

func _on_hurt_timer_timeout() -> void:
	hurt = false

func _on_attack_duration_timeout() -> void:
	attacking = false

func _on_atk_cd_timeout() -> void:
	atk_in_cd=false
