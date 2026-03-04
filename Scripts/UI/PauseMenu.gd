# res://Scripts/UI/PauseMenu.gd
extends CanvasLayer

@onready var settings_panel  = $Control/SettingsPanel
@onready var sfx_slider      = $Control/SettingsPanel/MarginContainer/VBox/SFXRow/SFXSlider
@onready var music_slider    = $Control/SettingsPanel/MarginContainer/VBox/MusicRow/MusicSlider
@onready var sfx_label       = $Control/SettingsPanel/MarginContainer/VBox/SFXRow/SFXValueLabel
@onready var music_label     = $Control/SettingsPanel/MarginContainer/VBox/MusicRow/MusicValueLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # ทำงานแม้เกม pause
	settings_panel.visible = false
	_load_volume_settings()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		# ถ้า settings เปิดอยู่ ให้ปิด settings ก่อน
		if settings_panel.visible:
			settings_panel.visible = false
			return
		_toggle_pause()

# ─── ปุ่มเล่นต่อ ───────────────────────────────────────────────────────────
func _on_resume_pressed() -> void:
	AudioManager.play_sound(AudioManager.COIN_PICK, 0, -5)
	_resume()

# ─── ปุ่มตั้งค่า ───────────────────────────────────────────────────────────
func _on_settings_pressed() -> void:
	AudioManager.play_sound(AudioManager.COIN_PICK, 0, -5)
	settings_panel.visible = !settings_panel.visible

func _on_close_settings_pressed() -> void:
	AudioManager.play_sound(AudioManager.COIN_PICK, 0, -5)
	settings_panel.visible = false

# ─── ปุ่มออกเกม ────────────────────────────────────────────────────────────
func _on_quit_pressed() -> void:
	AudioManager.play_sound(AudioManager.COIN_PICK, 0, -5)
	await get_tree().create_timer(0.15).timeout
	get_tree().paused = false
	get_tree().quit()

# ─── ฟังก์ชันภายใน ─────────────────────────────────────────────────────────
func _toggle_pause() -> void:
	var is_paused: bool = !get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused

func _resume() -> void:
	settings_panel.visible = false
	get_tree().paused = false
	visible = false

func _load_volume_settings() -> void:
	var sfx_index   = AudioServer.get_bus_index("SFX")
	var music_index = AudioServer.get_bus_index("Music")

	if sfx_index != -1:
		var v = db_to_linear(AudioServer.get_bus_volume_db(sfx_index))
		sfx_slider.value = v
		sfx_label.text   = str(int(v * 100)) + "%"
	else:
		sfx_slider.value = 1.0
		sfx_label.text   = "100%"

	if music_index != -1:
		var v = db_to_linear(AudioServer.get_bus_volume_db(music_index))
		music_slider.value = v
		music_label.text   = str(int(v * 100)) + "%"
	else:
		music_slider.value = 1.0
		music_label.text   = "100%"

func _on_sfx_slider_changed(value: float) -> void:
	sfx_label.text = str(int(value * 100)) + "%"
	var safe_val   = max(value, 0.001)
	var idx        = AudioServer.get_bus_index("SFX")
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(safe_val))
	AudioManager.play_sound(AudioManager.COIN_PICK, 0, linear_to_db(safe_val) - 10)

func _on_music_slider_changed(value: float) -> void:
	music_label.text = str(int(value * 100)) + "%"
	var safe_val     = max(value, 0.001)
	var idx          = AudioServer.get_bus_index("Music")
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(safe_val))
