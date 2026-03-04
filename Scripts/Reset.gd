# res://Scripts/Reset.gd
# แทนที่ไฟล์เดิม
# DeathScreen / VictoryScreen ใช้ script นี้
# เมื่อ player ตาย (ไม่ใช่หมดเวลา) → fail_level ถูกเรียกที่นี่
extends Node

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Restart"):
		restart()
	if Input.is_action_just_pressed("Escape"):
		get_tree().quit()
	if Input.is_action_just_pressed("Enter"):
		GameManager.reset_run()
		get_tree().change_scene_to_file("res://Scenes/Levels/MainLobbyFloor.tscn")

func restart() -> void:
	# บันทึก fail เฉพาะกรณีที่ timer ยังทำงานอยู่ (ตายก่อนหมดเวลา)
	# ถ้าหมดเวลาแล้ว LevelChallengeManager จัดการไปแล้ว
	if GameManager.timer_active:
		GameManager.fail_level()
	GameManager.stop_timer()
	GameManager.reset_money()
	GameManager.load_same_level()
