extends Area2D
@onready var label = $Label
@export var next_scene_path : String = ""
@export var heal_player : bool = false
func _ready():
	label.visible = false
func _process(_delta):
	if Input.is_action_just_pressed("Enter") and label.visible == true:
		GameManager.heal_on_next_level = heal_player
		get_tree().change_scene_to_file(next_scene_path)
func _on_body_entered(body):
	if body.is_in_group("Player"):
		label.visible = true
func _on_body_exited(body):
	if body.is_in_group("Player"):
		label.visible = false
