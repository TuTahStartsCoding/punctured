# res://Scripts/UI/ScoreRow.gd
extends PanelContainer

@onready var level_label:  Label = $RowMargin/HBox/LevelLabel
@onready var status_label: Label = $RowMargin/HBox/StatusLabel
@onready var time_label:   Label = $RowMargin/HBox/TimeLabel
@onready var coin_label:   Label = $RowMargin/HBox/CoinLabel

func setup(record: Dictionary) -> void:
	assert(level_label  != null, "LevelLabel is NULL")
	assert(status_label != null, "StatusLabel is NULL")
	assert(time_label   != null, "TimeLabel is NULL")
	assert(coin_label   != null, "CoinLabel is NULL")

	level_label.text = record.get("level_name", "?")

	var completed: bool = record.get("completed", false)
	if completed:
		status_label.text     = "PASS"
		status_label.modulate = Color(0.4, 1.0, 0.4)
	else:
		status_label.text     = "FAIL"
		status_label.modulate = Color(1.0, 0.4, 0.4)

	var t: float   = record.get("time_used", 0.0)
	@warning_ignore("integer_division")
	var mins: int  = int(t) / 60
	var secs: int  = int(t) % 60
	time_label.text = "%02d:%02d" % [mins, secs]

	coin_label.text = "%d" % record.get("coins", 0)
