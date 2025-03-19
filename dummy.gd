extends CharacterBody2D

#region New Code Region
@onready var audio= AudioStreamPlayer2D.new()
const p_bar = preload("res://p_bar.tscn")
const dmg_num = preload("res://dmg_num.tscn")
const drop = preload("res://drop.tscn")
var sound=[
	preload("res://assets/sounds/sword-sound.mp3"),
	preload("res://assets/sounds/sword-sound_.mp3"),
	preload("res://assets/sounds/sword-stab.mp3"),
	preload("res://assets/sounds/blank.mp3"),
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
var z_index_options = [1,-1]
var hurt = false
var hurt_duration = 1
var speed = 100
var atk_cd = 2.0
var level : int
var can_attack = false
var facing_right = false
var can_move = false
var atk_in_cd = false
#endregion

func set_enemy_stats():
	# Normal enemy scaling
	max_hp = 5 # Increased power factor for ATK
	max_def = 1  # Slightly slower DEF scaling

func move():
	if facing_right:
		velocity.x = speed
	else:
		velocity.x = -speed

func _ready() -> void:
	add_to_group("enemy")
	set_enemy_stats()
	$Label.text="Lv. "+str(level)
	def = max_def
	hp = max_hp
	bar.max_value = max_hp
	bar.value = hp
	bar.for_enemy = true
	add_child(bar)
	get_parent().add_child(audio) #bug
	audio.process_mode=Node.PROCESS_MODE_ALWAYS
	z_index=z_index_options.pick_random()
	if g.sound_on:
		audio.stream=sound[4]
		audio.play()
	facing_right=false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta *4
		velocity.x = 0
	elif !hurt:
		if abs(g.player.global_position.x-global_position.x)>100:
			if g.player.global_position.x>global_position.x:
				if !facing_right:
					facing_right = true
			elif g.player.global_position.x<global_position.x:
				if facing_right:
					facing_right = false
			can_move = true
			move()
		else:
			can_move=false
			velocity.x = 0
	move_and_slide()

func hit(dmg):
	$hurt_timer.stop()
	hurt = true
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
	get_parent().get_parent().enemy_killed +=1
	get_parent().get_parent().total_enemy_killed +=1
	queue_free()

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
