# res://Scripts/UI/TimerHUD.gd
# ══════════════════════════════════════════════════════════════
#  แนบกับ Scenes/Challenge/TimerHUD.tscn (CanvasLayer layer=5)
#  แสดง: เวลาถอยหลัง | coin ด่านนี้ | coin สะสม
# ══════════════════════════════════════════════════════════════
extends CanvasLayer

@onready var timer_label: Label    = $HUDRoot/TopBar/BarHBox/BarMargin/InnerHBox/TimerPanel/TimerMargin/TimerLabel
@onready var coin_label: Label     = $HUDRoot/TopBar/BarHBox/BarMargin/InnerHBox/CoinPanel/CoinMargin/CoinLabel
@onready var total_label: Label    = $HUDRoot/TopBar/BarHBox/BarMargin/InnerHBox/TotalPanel/TotalMargin/TotalLabel
@onready var level_label: Label    = $HUDRoot/TopBar/BarHBox/BarMargin/InnerHBox/LevelLabel

var flash_timer: float = 0.0
var is_urgent: bool = false

func _ready() -> void:
	# อัพเดต ชื่อด่าน
	level_label.text = GameManager.current_level_name

func _process(delta: float) -> void:
	_update_timer(delta)
	_update_coins()

func _update_timer(delta: float) -> void:
	var t = GameManager.time_remaining
	var mins = int(t) / 60
	var secs = int(t) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]

	# สีตาม urgency
	if t <= 10.0:
		# กระพริบแดง เมื่อเวลาน้อยมาก
		flash_timer += delta
		if flash_timer >= 0.3:
			flash_timer = 0.0
			timer_label.modulate = Color.RED if timer_label.modulate == Color.WHITE else Color.WHITE
		if not is_urgent:
			is_urgent = true
			_shake_panel()
	elif t <= 30.0:
		timer_label.modulate = Color(1.0, 0.6, 0.0)   # ส้ม
		is_urgent = false
	else:
		timer_label.modulate = Color.WHITE
		is_urgent = false

func _update_coins() -> void:
	coin_label.text  = "%d" % GameManager.current_level_coins
	total_label.text = "%d" % GameManager.total_coins

func _shake_panel() -> void:
	# ใช้ scale แทน position เพราะ timer_label อยู่ใน Container (layout override position)
	var tween = create_tween()
	tween.tween_property(timer_label, "scale", Vector2(1.15, 1.15), 0.06)
	tween.tween_property(timer_label, "scale", Vector2(0.9, 0.9), 0.06)
	tween.tween_property(timer_label, "scale", Vector2(1.05, 1.05), 0.05)
	tween.tween_property(timer_label, "scale", Vector2.ONE, 0.05)
