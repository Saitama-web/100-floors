extends Control
#const cards = preload("res://card.tscn")
const player = preload("res://player.tscn")
const opponent = preload("res://opponent.tscn")
@onready var choice_panel: Panel = $choice_panel

var enemy_pos=Vector2(350,400)
var normal_attack_cd = 0.01
var skill_cd = 5
var burst_cd = 10
var enemy_killed = false
var gold=0
var def_scale_label
var wish = 0
var can_coin_animate= true
var dont_hit=true
var revive=false
#var can_summon_cards = true

func _ready() -> void:
	randomize()
	$choice_panel.hide()
	$Label.text = "enemy level : "+str(g.enemy_level)
	def_scale_label=$coins/Panel/Label.scale
	get_tree().root.connect("go_back_requested",_on_back_pressed)
	get_tree().quit_on_go_back = false
	summon_enemy(3)
	$scenery.show()

func on_coin_anim_finished():
	can_coin_animate=true

func coin_anim():
	$coins/Panel/Label.text=str(gold)
	if can_coin_animate:
		can_coin_animate=false
		var tween = create_tween()
		tween.tween_property($coins/Panel/Label,"scale:y",def_scale_label.y*1.5,0.1)
		tween.tween_property($coins/Panel/Label,"scale:y",def_scale_label.y*1,0.1)
		tween.finished.connect(on_coin_anim_finished)

#func _process(delta: float) -> void:
	#if enemy_killed:
		#enemy_killed=false
		#$Label.text = "enemy level : "+str(g.enemy_level)
		#summon_enemy()

func _on_back_pressed() -> void:
	g.save = true
	get_tree().change_scene_to_file("res://main.tscn")

func summon_enemy(num):
	var o = opponent.instantiate()
	var final_pos=enemy_pos
	o.position.y = 0
	o.position.x = randi_range(0,1150)
	await get_tree().create_timer(0.8).timeout
	add_child(o)
	var tween = create_tween()
	tween.tween_property(o,"position:y",final_pos.y,0.3).set_ease(Tween.EASE_IN)

func _on_button_2_pressed() -> void:
	_on_back_pressed()

func _on_button_pressed() -> void:
	revive=true
	get_tree().paused=false
	find_child("player").reset_atk_timer()
	$choice_panel.hide()
	$player.reset_hp()
	$player.show()
	#$player.use_card("revive",1)

#func _on_cards_timer_timeout() -> void:
	#can_summon_cards=true

func _on_spawn_enemy_pressed() -> void:
	summon_enemy(3)
