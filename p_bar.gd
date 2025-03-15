extends ProgressBar

var o_color=Color(0.9,0.3,0.0,1.0)
var p_color=Color(0.0,0.9,0.0,1.0)

var for_enemy = false
var color = o_color

func _ready() -> void:
	var scaler = 1
	var y_shift = 0
	if for_enemy:
		scaler = 0.4
		y_shift = 60
	var pos:Vector2
	scale=Vector2(1,1)*scaler
	pos.x=position.x-size.x/2*scale.x
	pos.y=position.y-y_shift
	set_position(pos)
