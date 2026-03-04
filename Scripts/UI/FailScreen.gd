# res://Scripts/UI/FailScreen.gd
extends CanvasLayer

@onready var time_label: Label = $Control/Panel/Margin/VBox/TimeLabel
@onready var coin_label: Label = $Control/Panel/Margin/VBox/CoinLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var t: float  = GameManager.time_limit
	var mins: int = int(t / 60 )
	var secs: int = int(t) % 60
	time_label.text = "เวลาที่ใช้: %02d:%02d" % [mins, secs]
	coin_label.text = "Coin: %d" % GameManager.current_level_coins

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Restart"):
		get_tree().paused = false
		GameManager.reset_money()
		queue_free()
		GameManager.load_same_level()

	elif Input.is_action_just_pressed("Enter"):
		get_tree().paused = false
		GameManager.reset_run()
		queue_free()
		get_tree().change_scene_to_file("res://Scenes/Levels/MainMenu.tscn")

	elif Input.is_action_just_pressed("Escape"):
		get_tree().paused = false
		queue_free()
		get_tree().quit()
