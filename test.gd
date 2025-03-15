extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for level in range(0,101):
		#num=10 * level + pow(level, 2.074) player hp
		#num = level * 2 + pow(level, 1.3)
		#num = level * 12.5 + pow(level,2.24) #enemy hp
		num = 1 + 2.5 * level + pow(level, 1.46)
		print(str(level)+". "+str(num))

var num=0
