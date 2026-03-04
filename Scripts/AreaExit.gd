# res://Scripts/AreaExit.gd
# แทนที่ไฟล์เดิม — เพิ่ม GameManager.complete_level() ก่อนเปลี่ยน scene
extends Area2D

@onready var label = $Label
@export var next_scene_path: String = ""
@export var heal_player: bool = false
@export var is_victory_door: bool = false   # ประตูสุดท้าย → ไป ScoreboardScreen

var _entered: bool = false   # guard double-trigger

func _ready() -> void:
	label.visible = false
	_entered = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Enter") and label.visible and not _entered:
		_entered = true
		_enter_door()

func _enter_door() -> void:
	GameManager.complete_level()
	GameManager.heal_on_next_level = heal_player

	if is_victory_door:
		get_tree().change_scene_to_file("res://Scenes/Challenge/ScoreboardScreen.tscn")
	elif next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	else:
		push_warning("AreaExit: next_scene_path is empty and is_victory_door is false!")
		_entered = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		label.visible = false
