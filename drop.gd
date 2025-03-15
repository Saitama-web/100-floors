extends Node2D
@onready var anim: AnimationPlayer = $AnimationPlayer
var audio = AudioStreamPlayer2D.new()
var sound=[
	preload("res://assets/sounds/coin0.mp3"),
	preload("res://assets/sounds/coin1.mp3"),
	preload("res://assets/sounds/coin2.mp3"),
	preload("res://assets/sounds/coin3.mp3"),
	preload("res://assets/sounds/wish1.mp3"),
	preload("res://assets/sounds/treasurefound.mp3")
]
var type = "coin"
func _ready() -> void:
	get_parent().add_child(audio)
	audio.stream=sound[1]
	if type=="coin":
		$Sprite2d.texture=preload("res://assets/icons/coin_01d.png")
		audio.stream=sound[1]
	elif type=="wish":
		$Sprite2d.texture=preload("res://assets/icons/gem_01d.png")
		audio.stream=sound[5]
		audio.volume_db = -6
		if g.sound_on:
			audio.play()
	anim.play("spawn")
	
	var tween = get_parent().create_tween()
	tween.parallel().tween_property(self,"position:x",randi_range(-100,100),0.8).set_ease(Tween.EASE_IN_OUT).as_relative()

func pickup():
	if type =="coin":
		audio.stream = sound[0]
	elif type =="wish":
		audio.stream=sound[4]
	if g.sound_on:
		audio.play()
	var tween = get_parent().create_tween()
	tween.parallel().tween_property(self,"modulate:a",0,0.3)
	tween.parallel().tween_property(self,"position:y",-200,0.3).set_ease(Tween.EASE_IN_OUT).as_relative()
	tween.finished.connect(Callable(self,"something"))

func something():
	if type=="coin":
		g.total_gold+=1
		if get_parent().name=="spawns":
			get_parent().get_parent().coin_anim()
		else:
			get_parent().coin_anim()
	elif type=="wish":
		g.wish_count+=1

	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		pickup()
