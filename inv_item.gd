extends TextureRect

#region New Code Region
var clicked = false
var icon : Texture2D
var details:Array
var level:int
var show_level : bool
#endregion

func _ready() -> void:
	if icon:
		call_deferred("set_texture",icon)
		if details:
			level = int(details[2])
		#if !level or !show_level:
			#$Panel.hide()
		#else:
			#$Panel.show()
			$Panel/level.text=str(level)

func _on_button_button_down() -> void:
	clicked=true

func _on_button_button_up() -> void:
	clicked=false
