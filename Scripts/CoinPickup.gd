# Scripts/CoinPickup.gd
extends Sprite2D

@export var value = 5
@export var heal_amount : int = 10

var time_passed = 0
var initial_position := Vector2.ZERO
@export var amplitude := 3.0
@export var frequency := 4.0

func _ready():
	initial_position = position

func _process(delta):
	body_hover(delta)

func body_hover(delta):
	time_passed += delta
	var new_y = initial_position.y + amplitude * sin(frequency * time_passed)
	position.y = new_y

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		GameManager.add_money(value)
		
		if body.has_method("_heal"):
			body._heal(heal_amount)
		
		AudioManager.play_sound(AudioManager.COIN_PICK, 0, -10)
		queue_free()
