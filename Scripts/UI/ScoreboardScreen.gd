# res://Scripts/UI/ScoreboardScreen.gd
extends Control

@onready var title_label:    Label         = $BG/HeaderPanel/HeaderMargin/TitleLabel
@onready var rows_container: VBoxContainer = $BG/ScrollContainer/RowsVBox
@onready var summary_label:  Label         = $BG/SummaryPanel/SummaryMargin/SummaryLabel
@onready var hint_label:     Label         = $BG/HintLabel

const ROW_SCENE = preload("res://Scenes/Challenge/ScoreRow.tscn")

func _ready() -> void:
	_build_table()
	_build_summary()

func _build_table() -> void:
	for record in GameManager.level_records:
		var row = ROW_SCENE.instantiate()
		rows_container.add_child(row)
		row.setup(record)

func _build_summary() -> void:
	var completed: int  = GameManager.get_completed_count()
	var total: int      = GameManager.level_records.size()
	var total_t: float  = GameManager.get_total_time()
	var mins: int       = int(total_t) / 60
	var secs: int       = int(total_t) % 60
	var coins: int      = GameManager.total_coins

	summary_label.text = (
		"ผ่านด่าน:  %d / %d\n"  % [completed, total] +
		"เวลารวม:   %02d:%02d\n" % [mins, secs] +
		"Coin รวม:  %d"          % coins
	)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Restart"):
		_play_again()
	if Input.is_action_just_pressed("Escape"):
		get_tree().quit()

func _play_again() -> void:
	GameManager.reset_run()
	get_tree().change_scene_to_file("res://Scenes/Levels/MainMenu.tscn")
