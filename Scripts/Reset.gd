# res://Scripts/Reset.gd
# DeathScreen / VictoryScreen ใช้ script นี้
extends Node

func _ready() -> void:
	# ทำงานได้แม้ tree ถูก pause (กรณีตายหลัง time_up)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Restart"):
		restart()
	if Input.is_action_just_pressed("Escape"):
		get_tree().paused = false
		get_tree().quit()
	if Input.is_action_just_pressed("Enter"):
		get_tree().paused = false
		GameManager.reset_run()
		get_tree().change_scene_to_file("res://Scenes/Levels/MainLobbyFloor.tscn")

func restart() -> void:
	if GameManager.timer_active:
		GameManager.fail_level()
	GameManager.stop_timer()
	GameManager.reset_money()
	get_tree().paused = false
	GameManager.load_same_level()
