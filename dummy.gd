extends CharacterBody2D

#region New Code Region
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

var bar = p_bar.instantiate()
var stun_duration = 2
var z_index_options = [1,-1]
var hurt = false
var speed = 100
var level = 0
#endregion

func set_enemy_stats(enemy_level: int):
	# Normal enemy scaling
	max_hp = round(enemy_level * 12.5 + pow(enemy_level,2.24))
	max_atk = round(enemy_level * 2 + pow(enemy_level, 1.3))  # Increased power factor for ATK
	max_def = round(enemy_level * 1.5 + pow(enemy_level, 1.2))  # Slightly slower DEF scaling

func _ready() -> void:
	add_to_group("enemy")
	set_enemy_stats(level)
	$Label.text="Lv. "+str(level)
	atk = max_atk
	def = max_def
	hp = max_hp
	bar.max_value = max_hp
	bar.value = hp
	bar.for_enemy = true
	add_child(bar)
	get_parent().add_child(audio) #bug
	audio.process_mode=Node.PROCESS_MODE_ALWAYS
	z_index=z_index_options.pick_random()
	audio.stream=sound[4]
	audio.play()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta *4
	if g.player:
		if !hurt:
			if abs(g.player.global_position.x-global_position.x)>100:
				if g.player.global_position.x>global_position.x:
					velocity.x = speed
				elif g.player.global_position.x<global_position.x:
					velocity.x = -speed
			else:
				velocity.x=0
	move_and_slide()

func hit(dmg):
	$hurt_timer.stop()
	hurt = true
	$hurt_timer.start(stun_duration)
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
		audio.stream = sound[2]
		audio.play()
		despawn()
	else:
		bar.value = hp
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
