# res://Scripts/Managers/GameManager.gd
extends Node

# ─────────────────────────────────────────────
#  SIGNALS
# ─────────────────────────────────────────────
signal timer_tick(remaining: float)
signal time_up()
signal level_complete(stats: Dictionary)

# ─────────────────────────────────────────────
#  SINGLE-PLAYER CORE
# ─────────────────────────────────────────────
var money: int = 0
var player_health: int = -1
var heal_on_next_level: bool = true

# ─────────────────────────────────────────────
#  TIMER
# ─────────────────────────────────────────────
var time_limit: float = 120.0
var time_remaining: float = 120.0
var timer_active: bool = false
var level_start_time: float = 0.0

# ─────────────────────────────────────────────
#  SCOREBOARD
# ─────────────────────────────────────────────
var level_records: Array = []
var current_level_name: String = ""
var current_level_coins: int = 0
var total_coins: int = 0

# ─────────────────────────────────────────────
#  READY — เปิด log file
# ─────────────────────────────────────────────
func _ready() -> void:
	# เขียน log ไฟล์เพื่อ debug .exe
	var log_path = OS.get_user_data_dir() + "/game_log.txt"
	var f = FileAccess.open(log_path, FileAccess.WRITE)
	if f:
		f.store_line("=== GAME STARTED ===")
		f.store_line("Time: " + Time.get_datetime_string_from_system())
		f.store_line("OS: " + OS.get_name())
		f.close()

func _log(msg: String) -> void:
	var log_path = OS.get_user_data_dir() + "/game_log.txt"
	var f = FileAccess.open(log_path, FileAccess.READ_WRITE)
	if f:
		f.seek_end()
		f.store_line(msg)
		f.close()

# ─────────────────────────────────────────────
#  PROCESS
# ─────────────────────────────────────────────
func _process(delta: float) -> void:
	# F11 toggle fullscreen — ช่วย debug .exe
	if Input.is_action_just_pressed("ui_cancel"):
		pass  # อย่า quit ที่นี่ ให้แต่ละ scene จัดการเอง

	if not timer_active:
		return
	time_remaining -= delta
	emit_signal("timer_tick", time_remaining)
	if time_remaining <= 0.0:
		time_remaining = 0.0
		timer_active = false
		_log("time_up emitted")
		emit_signal("time_up")

# ═══════════════════════════════════════════════
#  TIMER API
# ═══════════════════════════════════════════════
func start_level_timer(limit: float, lv_name: String) -> void:
	time_limit = limit
	time_remaining = limit
	current_level_name = lv_name
	current_level_coins = 0
	timer_active = true
	level_start_time = Time.get_ticks_msec() / 1000.0
	_log("start_level_timer: " + lv_name + " limit=" + str(limit))

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
#  LEVEL COMPLETE
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
	_log("complete_level: " + current_level_name)
	emit_signal("level_complete", stats)

# ═══════════════════════════════════════════════
#  FAIL
# ═══════════════════════════════════════════════
func fail_level() -> void:
	var stats = {
		"level_name": current_level_name,
		"time_used":  time_limit,
		"time_limit": time_limit,
		"coins":      current_level_coins,
		"completed":  false
	}
	level_records.append(stats)
	_log("fail_level: " + current_level_name)

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
	_log("reset_run")

# ═══════════════════════════════════════════════
#  SCENE LOADING
# ═══════════════════════════════════════════════
func load_next_level(next_scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(next_scene)

func load_same_level() -> void:
	_log("load_same_level")
	get_tree().reload_current_scene()

func save_player_health(hp: int) -> void:
	player_health = hp
