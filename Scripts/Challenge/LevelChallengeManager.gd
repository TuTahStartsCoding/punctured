# res://Scripts/Challenge/LevelChallengeManager.gd
# ══════════════════════════════════════════════════════════════
#  วางเป็น Node ใน *ทุกด่าน* ที่ต้องการจับเวลา
#  ตั้งค่า level_name และ time_limit ใน Inspector
# ══════════════════════════════════════════════════════════════
extends Node

@export var level_name: String = "Level 1"
@export var time_limit: float = 120.0

const FAIL_SCREEN = preload("res://Scenes/Challenge/FailScreen.tscn")

var _fail_handled: bool = false   # guard double-fail

func _ready() -> void:
	_fail_handled = false
	# เชื่อม signal — ใช้ CONNECT_ONE_SHOT ป้องกัน fire ซ้ำ
	if not GameManager.time_up.is_connected(_on_time_up):
		GameManager.time_up.connect(_on_time_up)
	# เริ่มนับเวลา
	GameManager.start_level_timer(time_limit, level_name)

func _exit_tree() -> void:
	# ถอด signal เมื่อ node ถูก free (เปลี่ยน scene)
	if GameManager.time_up.is_connected(_on_time_up):
		GameManager.time_up.disconnect(_on_time_up)

func _on_time_up() -> void:
	if _fail_handled:
		return
	_fail_handled = true
	GameManager.fail_level()
	var fail = FAIL_SCREEN.instantiate()
	get_tree().root.add_child(fail)
