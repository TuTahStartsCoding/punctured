# res://Scripts/UI/TutorialBanner.gd
# ══════════════════════════════════════════════════════════════
#  วางใน CanvasLayer ของด่านแรก (MainLobbyFloor)
#  แสดงข้อความสอนเล่นแบบ popup banner ตามลำดับ
#  trigger จาก: เวลา, input, หรือเหตุการณ์ใน game
# ══════════════════════════════════════════════════════════════
extends CanvasLayer

@onready var banner_panel = $BannerPanel
@onready var banner_label: Label = $BannerPanel/Margin/Label
@onready var arrow_label: Label  = $BannerPanel/Arrow

# ข้อความแต่ละขั้น (index = step)
const TIPS: Array[String] = [
	"ยินดีต้อนรับ! \n กด WASD เพื่อเดิน",
	"กด SPACE เพื่อ Dash พุ่งหนีศัตรู!",
	"คลิกซ้าย / กด J เพื่อ Punch \n คลิกขวา / กด K เพื่อ Kick",
	"เก็บ Coin เพิ่มเลือดและคะแนน! \n Coin = คะแนน + HP",
	"มีเวลาจำกัดในแต่ละด่าน! \n ผ่านให้ทันก่อนหมดเวลา",
	"หาประตู Exit เพื่อไปด่านถัดไป \n กด E ที่ประตูเพื่อผ่านด่าน",
	"คะแนนดูได้ที่ Scoreboard ตอนจบเกม! \n โชคดีนะ!"
]

var showing: bool = false
var auto_shown: Array[bool] = []   # ป้องกันแสดงซ้ำ

func _ready() -> void:
	banner_panel.visible = false
	auto_shown.resize(TIPS.size())
	auto_shown.fill(false)
	# แสดง tip แรกหลัง 1 วินาที
	await get_tree().create_timer(1.0).timeout
	show_tip(0)

func _process(delta: float) -> void:
	# ตรวจ input เพื่อ trigger tip
	if not auto_shown[1] and Input.get_vector("MoveLeft","MoveRight","MoveUp","MoveDown").length() > 0.1:
		show_tip(1)
	if not auto_shown[2] and (Input.is_action_just_pressed("Punch") or Input.is_action_just_pressed("Kick")):
		show_tip(2)
	if not auto_shown[3] and GameManager.current_level_coins > 0:
		show_tip(3)
	if not auto_shown[4] and GameManager.time_remaining < GameManager.time_limit - 10.0:
		show_tip(4)

# ══ แสดง tip ตาม index ══
func show_tip(index: int) -> void:
	if index >= TIPS.size() or auto_shown[index] or showing:
		return
	auto_shown[index] = true
	showing = true
	banner_label.text = TIPS[index]

	# Animate เข้า
	banner_panel.visible = true
	banner_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(banner_panel, "modulate:a", 1.0, 0.3)
	tween.tween_interval(3.5)
	tween.tween_property(banner_panel, "modulate:a", 0.0, 0.4)
	await tween.finished
	banner_panel.visible = false
	showing = false

# เรียกจาก script ภายนอกได้ (เช่น NPC trigger)
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
