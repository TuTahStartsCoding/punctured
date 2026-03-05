# res://Scripts/UI/TutorialBanner.gd
extends CanvasLayer

@onready var banner_panel = $BannerPanel
@onready var banner_label: Label = $BannerPanel/Margin/Label

# 9 tips × ~2.2 วิ = ~20 วิรวม
const TIPS: Array[String] = [
	"Punctured Catacombs\nยินดีต้อนรับ!",
	"เป้าหมาย: ผ่านทุกด่านให้ทันเวลา\nเก็บ Coin และเอาชีวิตรอด!",
	"กด W A S D เพื่อเดิน",
	"กด SPACE พร้อม W, A, S, D เพื่อ Dash",
	"คลิกซ้าย / J : Punch\nคลิกขวา / K : Kick",
	"กด ESC หยุดเกมชั่วคราว",
	"เก็บ Coin เพิ่มเลือดและคะแนน",
	"หาประตู Exit แล้วกด E เพื่อผ่านด่าน",
	"มีเวลาจำกัด — ผ่านให้ทันก่อนหมดเวลา!"
]

# เวลาแต่ละ tip: fade_in=0.3 + show=1.5 + fade_out=0.4 = 2.2 วิ × 9 = 19.8 วิ
const SHOW_DURATION  := 2.5
const FADE_IN_TIME   := 0.3
const FADE_OUT_TIME  := 0.4

var showing: bool = false

func _ready() -> void:
	banner_panel.visible = false
	await get_tree().create_timer(0.5).timeout
	_run_all_tips()

func _run_all_tips() -> void:
	for i in TIPS.size():
		await _show_tip(TIPS[i])

func _show_tip(text: String) -> void:
	showing = true
	banner_label.text = text
	banner_panel.visible = true
	banner_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(banner_panel, "modulate:a", 1.0, FADE_IN_TIME)
	tween.tween_interval(SHOW_DURATION)
	tween.tween_property(banner_panel, "modulate:a", 0.0, FADE_OUT_TIME)
	await tween.finished
	banner_panel.visible = false
	showing = false

func show_custom(text: String) -> void:
	await _show_tip(text)
