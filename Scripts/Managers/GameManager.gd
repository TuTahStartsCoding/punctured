extends Node

var money = 0
var player_health : int = -1
var heal_on_next_level : bool = true  # true = heal เต็มตอนเริ่มด่านใหม่

func reset_money():
	money = 0

func add_money(addmoney : int):
	money += addmoney

func load_next_level(next_scene : PackedScene):
	get_tree().change_scene_to_packed(next_scene)

func load_same_level():
	get_tree().reload_current_scene()

func save_player_health(hp : int):
	player_health = hp
