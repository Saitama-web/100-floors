extends Panel
#need some favor points to use cards of different costs
var cards = ["atk","heal","def"]
var super_cards = ["freeze","invinsible","duck"]
var value = [2,2,2,2,2,3,3,3,5]
var duration = [1]
var card_is_clicked=false
var card_name
var card_value
var drag=false
var drag_i 
var drag_f
var init_pos : Vector2
var offset : Vector2
var click_pos : Vector2

func _ready() -> void:
	pivot_offset=size/2
	init_pos=position
	click_pos.x=init_pos.x
	click_pos.y=init_pos.y-size.y/5
	update_card()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		drag_i=get_global_mouse_position()
		if get_rect().has_point(drag_i):
			offset=drag_i-global_position
			if !card_is_clicked:
				position.y= click_pos.y
				card_is_clicked=true
			drag = true
		else:
			if card_is_clicked:
				position.y=init_pos.y
				card_is_clicked=false
	if Input.is_action_pressed("click"):
		if drag:
			position = get_global_mouse_position()-offset

	if Input.is_action_just_released("click"):
		if drag:
			drag_f = get_global_mouse_position()
			if drag_f.y-drag_i.y<-size.y/2:
				get_tree().get_first_node_in_group("player").use_card(card_name,card_value)
				hide()
				for child in get_parent().get_children():
					var tween = create_tween()
					tween.tween_property(child,"position:y",size.y,0.5).set_delay(0.3).as_relative()
					tween.finished.connect(Callable(child,"queue_free"))
			else:
				if card_is_clicked:
					position=click_pos
				else:
					position=init_pos
		drag = false

func create_card():
	randomize()
	card_name=cards.pick_random()
	card_value = value.pick_random()

func update_card():
	if card_name=="heal":
		$Label.text = "heal player completely"
	else:
		$Label.text = "increase "+card_name+" by "+str(card_value)
	$Label.text+="\n\n\n\n\n\nSWIPE UP TO USE"
	$TextureRect.self_modulate = get_card_color(card_name, card_value)

func get_card_color(card_type: String, card_value: int = 0) -> Color:
	var color_map = {
		"heal": Color(0, 0.9, 0, 1.0),  # Single color for heal
		"atk": {
			2: Color(1.0, 0.3, 0.3),
			3: Color(0.8, 0.2, 0.2),
			5: Color(0.6, 0.0, 0.0)
		},
		"def": {
			2: Color(0.3, 0.3, 1.0),
			3: Color(0.2, 0.2, 0.8),
			5: Color(0.0, 0.0, 0.6)
		}
	}
	
	# Get the default panel color from the theme
	var default_color = Color(0.827, 0.827, 0.827, 1.0)

	
	# Handle "heal" case
	if card_type == "heal":
		return color_map["heal"]
	
	# Handle "atk" and "def" cases
	if card_type in color_map and card_value in color_map[card_type]:
		return color_map[card_type][card_value]
	
	return default_color
