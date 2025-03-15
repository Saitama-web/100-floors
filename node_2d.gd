extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func loop():
	for i in range(1000):
		print(i)
		if i==100:
			return
