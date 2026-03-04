# res://Scripts/Managers/GameManager.gd
# ══════════════════════════════════════════════════════════════
#  แทนที่ GameManager เดิมทั้งหมด
#  เพิ่ม: per-level timer, คะแนน coin, scoreboard data
# ══════════════════════════════════════════════════════════════
extends Node

# ─────────────────────────────────────────────
#  SIGNALS
# ─────────────────────────────────────────────
signal timer_tick(remaining: float)   # เรียกทุก frame
signal time_up()                       # หมดเวลา → แพ้
signal level_complete(stats: Dictionary)  # ผ่านด่านสำเร็จ

# ─────────────────────────────────────────────
#  SINGLE-PLAYER CORE (ระบบเดิม)
# ─────────────────────────────────────────────
var money: int = 0
var player_health: int = -1
var heal_on_next_level: bool = true

# ─────────────────────────────────────────────
#  TIMER
# ─────────────────────────────────────────────
var time_limit: float = 120.0       # กำหนดต่อด่าน (วินาที)
var time_remaining: float = 120.0
var timer_active: bool = false
var level_start_time: float = 0.0   # สำหรับคำนวณเวลาที่ใช้จริง

# ─────────────────────────────────────────────
#  SCOREBOARD  (เก็บสถิติต่อด่าน)
# ─────────────────────────────────────────────
# รูปแบบแต่ละ entry:
# { "level_name": String, "time_used": float, "coins": int, "completed": bool }
var level_records: Array = []

var current_level_name: String = ""
var current_level_coins: int = 0    # coin ที่เก็บในด่านนี้
var total_coins: int = 0            # coin สะสมทุกด่าน

# ─────────────────────────────────────────────
#  PROCESS — นับเวลาถอยหลัง
# ─────────────────────────────────────────────
func _process(delta: float) -> void:
	if not timer_active:
		return
	time_remaining -= delta
	emit_signal("timer_tick", time_remaining)
	if time_remaining <= 0.0:
		time_remaining = 0.0
		timer_active = false
		emit_signal("time_up")

# ═══════════════════════════════════════════════
#  TIMER API
# ═══════════════════════════════════════════════
func start_level_timer(limit: float, level_name: String) -> void:
	time_limit = limit
	time_remaining = limit
	current_level_name = level_name
	current_level_coins = 0
	timer_active = true
	level_start_time = Time.get_ticks_msec() / 1000.0

func stop_timer() -> void:
	timer_active = false

func get_time_used() -> float:
	return time_limit - time_remaining

# ═══════════════════════════════════════════════
#  COIN / MONEY
# ═══════════════════════════════════════════════
func add_money(amount: int) -> void:
	money += amount
	current_level_coins += amount
	total_coins += amount

func reset_money() -> void:
	money = 0

# ═══════════════════════════════════════════════
#  LEVEL COMPLETE  — เรียกจาก AreaExit หรือ Victory door
# ═══════════════════════════════════════════════
func complete_level() -> void:
	var time_used = get_time_used()
	stop_timer()

	var stats = {
		"level_name": current_level_name,
		"time_used":  time_used,
		"time_limit": time_limit,
		"coins":      current_level_coins,
		"completed":  true
	}
	level_records.append(stats)
	emit_signal("level_complete", stats)

# ═══════════════════════════════════════════════
#  FAIL (หมดเวลา หรือตาย) — บันทึกว่าไม่ผ่าน
# ═══════════════════════════════════════════════
func fail_level() -> void:
	var stats = {
		"level_name": current_level_name,
		"time_used":  time_limit,   # ใช้เวลาเต็ม = fail
		"time_limit": time_limit,
		"coins":      current_level_coins,
		"completed":  false
	}
	level_records.append(stats)

# ═══════════════════════════════════════════════
#  SCOREBOARD HELPERS
# ═══════════════════════════════════════════════
func get_total_time() -> float:
	var t = 0.0
	for r in level_records:
		if r["completed"]:
			t += r["time_used"]
	return t

func get_completed_count() -> int:
	var c = 0
	for r in level_records:
		if r["completed"]:
			c += 1
	return c

func reset_run() -> void:
	money = 0
	total_coins = 0
	current_level_coins = 0
	level_records.clear()
	timer_active = false
	player_health = -1
	heal_on_next_level = true

# ═══════════════════════════════════════════════
#  SCENE LOADING (ระบบเดิม)
# ═══════════════════════════════════════════════
func load_next_level(next_scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(next_scene)

func load_same_level() -> void:
	get_tree().reload_current_scene()

func save_player_health(hp: int) -> void:
	player_health = hp
