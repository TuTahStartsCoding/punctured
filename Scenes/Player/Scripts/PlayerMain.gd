# res://Scenes/Player/Scripts/PlayerMain.gd
extends CharacterBase
class_name PlayerMain

@onready var fsm = $FSM as FiniteStateMachine

const FAIL_SCREEN = preload("res://Scenes/Challenge/FailScreen.tscn")

func _die():
	super()                        # CharacterBase._die() → is_dead = true, await 1s, queue_free
	fsm.force_change_state("Die")  # เล่น animation ตาย

	# รอให้ animation ตายเล่นจบ (Death มี 4 frame × 0.1s ≈ 0.4s)
	await get_tree().create_timer(0.8).timeout

	# บันทึก fail เฉพาะกรณีที่ timer ยังทำงานอยู่
	if GameManager.timer_active:
		GameManager.fail_level()

	# หยุดเพลง
	_stop_music()

	# Pause เกม
	get_tree().paused = true

	# แสดง FailScreen
	var fail = FAIL_SCREEN.instantiate()
	get_tree().root.add_child(fail)

func _stop_music() -> void:
	var scene = get_tree().current_scene
	if scene:
		_stop_audio_recursive(scene)

func _stop_audio_recursive(node: Node) -> void:
	if node is AudioStreamPlayer:
		if (node as AudioStreamPlayer).playing:
			(node as AudioStreamPlayer).stop()
	for child in node.get_children():
		_stop_audio_recursive(child)
