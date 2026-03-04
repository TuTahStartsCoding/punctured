# res://Scripts/CoinPickup.gd
# แทนที่ไฟล์เดิม — coin เพิ่มเลือด + เพิ่มคะแนน
extends Sprite2D

@export var value: int = 5
@export var heal_amount: int = 10

var time_passed: float = 0.0
var initial_position := Vector2.ZERO
@export var amplitude: float = 3.0
@export var frequency: float = 4.0

func _ready() -> void:
	initial_position = position

func _process(delta: float) -> void:
	time_passed += delta
	position.y = initial_position.y + amplitude * sin(frequency * time_passed)

func _on_area_2d_body_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return

	# เพิ่มเงิน/คะแนน
	GameManager.add_money(value)

	# เพิ่มเลือด
	if body.has_method("_heal"):
		body._heal(heal_amount)

	AudioManager.play_sound(AudioManager.COIN_PICK, 0, -10)
	queue_free()
