# res://Scripts/UI/ScoreRow.gd
# แนบกับ Scenes/Challenge/ScoreRow.tscn
# แสดง 1 แถวใน scoreboard
extends PanelContainer

@onready var level_label:  Label = $RowMargin/HBox/LevelLabel
@onready var status_label: Label = $RowMargin/HBox/StatusLabel
@onready var time_label:   Label = $RowMargin/HBox/TimeLabel
@onready var coin_label:   Label = $RowMargin/HBox/CoinLabel

func setup(record: Dictionary) -> void:
	level_label.text = record.get("level_name", "?")

	var completed = record.get("completed", false)
	if completed:
		status_label.text = "✅ ผ่าน"
		status_label.modulate = Color(0.4, 1.0, 0.4)
	else:
		status_label.text = "❌ หมดเวลา"
		status_label.modulate = Color(1.0, 0.4, 0.4)

	var t = record.get("time_used", 0.0)
	var mins = int(t) / 60
	var secs = int(t) % 60
	time_label.text = "%02d:%02d" % [mins, secs]

	coin_label.text = "🪙 %d" % record.get("coins", 0)
