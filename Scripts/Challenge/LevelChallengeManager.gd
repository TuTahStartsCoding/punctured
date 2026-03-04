# res://Scripts/Challenge/LevelChallengeManager.gd
# วางเป็น Node ในทุกด่านที่ต้องการจับเวลา
# ตั้งค่า level_name และ time_limit ใน Inspector
extends Node

@export var level_name: String = "Level 1"
@export var time_limit: float = 120.0

const FAIL_SCREEN = preload("res://Scenes/Challenge/FailScreen.tscn")

var _fail_handled: bool = false
var _warned_30: bool = false   # เตือนครั้งแรกตอน 30 วิ
var _warned_10: bool = false   # เตือนครั้งที่สองตอน 10 วิ

func _ready() -> void:
	_fail_handled = false
	_warned_30 = false
	_warned_10 = false
	if not GameManager.time_up.is_connected(_on_time_up):
		GameManager.time_up.connect(_on_time_up)
	GameManager.start_level_timer(time_limit, level_name)

func _process(_delta: float) -> void:
	if not GameManager.timer_active:
		return
	var t = GameManager.time_remaining

	# เสียงเตือน 30 วินาที — ใช้ QUEST_SOUND
	if not _warned_30 and t <= 30.0:
		_warned_30 = true
		AudioManager.play_sound(AudioManager.QUEST_SOUND, 0.0, -5)

	# เสียงเตือน 10 วินาที — เล่น QUEST_SOUND เสียงดังขึ้น
	if not _warned_10 and t <= 10.0:
		_warned_10 = true
		AudioManager.play_sound(AudioManager.QUEST_SOUND, 0.0, 2)

func _exit_tree() -> void:
	if GameManager.time_up.is_connected(_on_time_up):
		GameManager.time_up.disconnect(_on_time_up)

func _on_time_up() -> void:
	if _fail_handled:
		return
	_fail_handled = true
	GameManager.fail_level()

	# หยุดเพลง (ค้นหา AudioStreamPlayer ทุกตัวในด่าน)
	_stop_music()

	# Pause เกม — ผู้เล่นและ enemy หยุดทั้งหมด
	get_tree().paused = true

	# แสดง FailScreen (ต้องทำงานได้แม้ paused)
	var fail = FAIL_SCREEN.instantiate()
	get_tree().root.add_child(fail)

func _stop_music() -> void:
	# หยุด AudioStreamPlayer ทุกตัวในด่านปัจจุบัน (bus=Music)
	var players = get_tree().get_nodes_in_group("music_player")
	for p in players:
		if p is AudioStreamPlayer:
			p.stop()
	# fallback: หา AudioStreamPlayer ที่เล่นอยู่ใน scene tree
	_stop_audio_recursive(get_tree().current_scene)

func _stop_audio_recursive(node: Node) -> void:
	if node is AudioStreamPlayer:
		var asp := node as AudioStreamPlayer
		if asp.playing:
			asp.stop()
	for child in node.get_children():
		_stop_audio_recursive(child)
