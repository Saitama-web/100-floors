extends RigidBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
const drop = preload("res://drop.tscn")

var sound=[
preload("res://assets/sounds/stone.mp3")
]
var type= "common"
var audio = AudioStreamPlayer2D.new()

func _ready() -> void:
	get_parent().add_child(audio)
	add_to_group("chest")
	anim.play("closed_"+type)
	if type == "common":
		$AnimatedSprite2D.scale*=2
		$CollisionShape2D.scale*=2
	elif type == "rare":
		$AnimatedSprite2D.scale*=(2*1.5)
		$CollisionShape2D.scale*=(2*1.5)
	elif type == "legendary":
		$AnimatedSprite2D.scale*=(2*2)
		$CollisionShape2D.scale*=(2*2)

func open():
	anim.play("open_"+type)
	collision_layer=4
	collision_mask=1
	$dissolve_timer.start(2.5)
	if g.sound_on:
		audio.stream=sound[0]
		audio.play()
	spawn_rewards()

func _on_dissolve_timer_timeout() -> void:
	queue_free()

func spawn_rewards():
	await get_tree().create_timer(0.5).timeout
	if type == "common":
		for i in range(10):
			var a = drop.instantiate()
			a.position=position
			a.position.y = position.y + 25
			a.type="coin"
			get_parent().add_child(a)
			await get_tree().create_timer(0.05).timeout
		for i in range(2):
			var a = drop.instantiate()
			a.position=position
			a.position.y = position.y + 25
			a.type="wish"
			get_parent().add_child(a)
			await get_tree().create_timer(0.05).timeout
	elif type == "rare":
		for i in range(20):
			var a = drop.instantiate()
			a.position=position
			a.position.y = position.y+50*1.5
			a.type="coin"
			get_parent().add_child(a)
			await get_tree().create_timer(0.05).timeout
		for i in range(10):
			var a = drop.instantiate()
			a.position.y = position.y+50*1.5
			a.type="wish"
			get_parent().add_child(a)
			await get_tree().create_timer(0.05).timeout
	elif type == "legendary":
		for i in range(20):
			var a = drop.instantiate()
			a.position=position
			a.position.y = position.y+50*2
			a.type="coin"
			get_parent().add_child(a)
			await get_tree().create_timer(0.05).timeout
		for i in range(10):
			var a = drop.instantiate()
			a.position.y = position.y+50*2
			a.type="wish"
			get_parent().add_child(a)
			await get_tree().create_timer(0.05).timeout
