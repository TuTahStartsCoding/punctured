# res://Scripts/UI/TutorialBanner.gd
extends CanvasLayer

@onready var banner_panel = $BannerPanel
@onready var banner_label: Label = $BannerPanel/Margin/Label

# Tips แสดงตามลำดับ — แต่ละข้อมีเงื่อนไข trigger ของตัวเอง
const TIPS: Array[String] = [
	"ยินดีต้อนรับ!\nกด W A S D เพื่อเดิน",         # 0 - แสดงทันที
	"กด SPACE เพื่อ Dash พุ่งหนีศัตรู",              # 1 - หลังเดินครั้งแรก
	"คลิกซ้าย / กด J : Punch\nคลิกขวา / กด K : Kick", # 2 - หลังเดินครั้งแรก (queue)
	"เก็บ Coin เพิ่มเลือดและคะแนน",                  # 3 - หลังเก็บ coin ครั้งแรก
	"มีเวลาจำกัดในแต่ละด่าน\nผ่านให้ทันก่อนหมดเวลา",  # 4 - หลัง 15 วิ
	"หาประตู Exit เพื่อไปด่านถัดไป\nกด E ที่ประตูเพื่อผ่าน", # 5 - หลัง 30 วิ
	"คะแนนดูได้ที่ Scoreboard ตอนจบเกม"             # 6 - หลัง 60 วิ
]

var showing: bool = false
var auto_shown: Array[bool] = []
var _tip_queue: Array[int] = []   # รายการ tip ที่รอแสดง

# tracking เงื่อนไข
var _has_moved: bool = false
var _has_attacked: bool = false
var _has_coin: bool = false

func _ready() -> void:
	banner_panel.visible = false
	auto_shown.resize(TIPS.size())
	auto_shown.fill(false)
	# tip 0 แสดงทันทีหลัง 1 วิ
	await get_tree().create_timer(1.0).timeout
	_queue_tip(0)

func _process(_delta: float) -> void:
	# ตรวจ trigger — queue tip ไว้ก่อน แสดงทีหลัง
	if not _has_moved and Input.get_vector("MoveLeft","MoveRight","MoveUp","MoveDown").length() > 0.1:
		_has_moved = true
		_queue_tip(1)    # Dash tip
		_queue_tip(2)    # Attack tip (ต่อจาก Dash)

	if not _has_attacked and (Input.is_action_just_pressed("Punch") or Input.is_action_just_pressed("Kick")):
		_has_attacked = true
		_queue_tip(2)

	if not _has_coin and GameManager.current_level_coins > 0:
		_has_coin = true
		_queue_tip(3)

	if not auto_shown[4] and GameManager.timer_active and \
		GameManager.time_limit - GameManager.time_remaining >= 15.0:
		_queue_tip(4)

	if not auto_shown[5] and GameManager.timer_active and \
		GameManager.time_limit - GameManager.time_remaining >= 30.0:
		_queue_tip(5)

	if not auto_shown[6] and GameManager.timer_active and \
		GameManager.time_limit - GameManager.time_remaining >= 60.0:
		_queue_tip(6)

	# ถ้าไม่มี tip แสดงอยู่ และมี queue → แสดงถัดไป
	if not showing and _tip_queue.size() > 0:
		var next = _tip_queue.pop_front()
		_show_tip_now(next)

func _queue_tip(index: int) -> void:
	# เพิ่มเข้า queue เฉพาะที่ยังไม่แสดง และไม่ซ้ำใน queue
	if index < TIPS.size() and not auto_shown[index] and not (index in _tip_queue):
		_tip_queue.append(index)

func _show_tip_now(index: int) -> void:
	if index >= TIPS.size() or auto_shown[index]:
		return
	auto_shown[index] = true
	showing = true
	banner_label.text = TIPS[index]
	banner_panel.visible = true
	banner_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(banner_panel, "modulate:a", 1.0, 0.3)
	tween.tween_interval(3.5)
	tween.tween_property(banner_panel, "modulate:a", 0.0, 0.4)
	await tween.finished
	banner_panel.visible = false
	showing = false

func show_custom(text: String) -> void:
	if showing:
		return
	showing = true
	banner_label.text = text
	banner_panel.visible = true
	banner_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(banner_panel, "modulate:a", 1.0, 0.3)
	tween.tween_interval(4.0)
	tween.tween_property(banner_panel, "modulate:a", 0.0, 0.4)
	await tween.finished
	banner_panel.visible = false
	showing = false
