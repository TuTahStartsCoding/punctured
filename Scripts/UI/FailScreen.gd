# res://Scripts/UI/FailScreen.gd
# แนบกับ Scenes/Challenge/FailScreen.tscn
extends CanvasLayer

@onready var time_label: Label  = $Control/Panel/Margin/VBox/TimeLabel
@onready var coin_label: Label  = $Control/Panel/Margin/VBox/CoinLabel

func _ready() -> void:
	var t = GameManager.time_limit - GameManager.time_remaining
	var mins = int(t) / 60
	var secs = int(t) % 60
	time_label.text = "เวลาที่ใช้: %02d:%02d / %02d:%02d" % [
		mins, secs,
		int(GameManager.time_limit) / 60,
		int(GameManager.time_limit) % 60
	]
	coin_label.text = "Coin ด่านนี้: 🪙 %d" % GameManager.current_level_coins

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Restart"):
		_retry()
	if Input.is_action_just_pressed("Escape"):
		get_tree().quit()
	if Input.is_action_just_pressed("Enter"):
		GameManager.reset_run()
		get_tree().change_scene_to_file("res://Scenes/Levels/MainMenu.tscn")

func _retry() -> void:
	# Reset money เฉพาะด่านนี้ แต่เก็บ record เดิม
	GameManager.reset_money()
	GameManager.load_same_level()
