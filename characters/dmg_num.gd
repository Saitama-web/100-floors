extends Label

var duration = 0.4
var pause_at_end = false
func _ready() -> void:
	#modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(self,"position:y",-60,duration).as_relative()#-20
	#tween.tween_property(self,"modulate:a",1,duration/2)
	tween.finished.connect(Callable(self,"remove"))

func remove():
	if pause_at_end:
		await get_tree().create_timer(0.8).timeout
		queue_free()
	queue_free()
