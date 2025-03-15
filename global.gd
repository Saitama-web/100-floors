extends Node

var rarity=["Legendary","Rare","Dull"]
var item=["Sword","Armour","Artifact"]
var data_loaded = false
var bag=[]
var equipped=[]
var wish_count = 5
var inv_capacity= 100
var total_gold = 0
var save = false
var last_scene
var can_attack= true
var can_skill=true
var can_burst=true
const s2 = preload("res://assets/swords/sword_03a.png")
const s1 = preload("res://assets/swords/sword_03d.png")
const s0 = preload("res://assets/swords/sword_03e.png")
const a2 = preload("res://assets/armour/armor_01a.png")
const a1 = preload("res://assets/armour/armor_01d.png")
const a0 = preload("res://assets/armour/armor_01e.png")
const r2 = preload("res://assets/artifact/ring_03a.png")
const r1 = preload("res://assets/artifact/ring_02d.png")
const r0 = preload("res://assets/artifact/ring_02e.png")
var swords=[s0,s1,s2]
var armours=[a0,a1,a2]
var artifacts=[r0,r1,r2]
var base_hp=0
var base_atk=0
var base_def=0
var added_hp=0
var added_atk=0
var added_def=0
var current_floor = 0
var player = null
var player_level=1
var enemy_level=0
var total_enemies_killed=0
