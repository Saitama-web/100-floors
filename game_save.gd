class_name saves
extends Resource

@export var bag : Array
@export var equipped : Array
@export var wish_count : int
#@export var inv_capacity:int
@export var total_gold : int
@export var current_floor : int
@export var player_level :int
@export var sound_on : bool
#@export var enemies_killed : int
#@export var total_enemies_killed : int


func from_g():
	bag = g.bag
	equipped = g.equipped
	wish_count = g.wish_count
	#inv_capacity = g.inv_capacity
	total_gold = g.total_gold
	current_floor = g.current_floor
	player_level = g.player_level
	sound_on = g.sound_on
	#enemies_killed = g.enemies_killed
	#total_enemies_killed = g.total_enemies_killed
func to_g():
	g.bag = self.bag
	g.equipped = self.equipped
	g.wish_count = self.wish_count
	#g.inv_capacity = self.inv_capacity
	g.total_gold = self.total_gold
	g.current_floor = self.current_floor
	g.player_level = self.player_level
	g.sound_on  = self.sound_on
	#g.enemies_killed = self.enemies_killed
	#g.total_enemies_killed = self.total_enemies_killed
