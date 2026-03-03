extends Control

@onready var settings_panel = $SettingsPanel
@onready var sfx_slider = $SettingsPanel/MarginContainer/VBox/SFXRow/SFXSlider
@onready var music_slider = $SettingsPanel/MarginContainer/VBox/MusicRow/MusicSlider
@onready var sfx_label = $SettingsPanel/MarginContainer/VBox/SFXRow/SFXValueLabel
@onready var music_label = $SettingsPanel/MarginContainer/VBox/MusicRow/MusicValueLabel

var menu_music : AudioStreamPlayer

func _ready():
	settings_panel.visible = false
	_start_menu_music()
	_load_volume_settings()
	# debug: พิมพ์ bus ที่มีทั้งหมด
	print("=== Audio Buses ===")
	for i in AudioServer.bus_count:
		print(i, ": ", AudioServer.get_bus_name(i))

func _start_menu_music():
	menu_music = AudioStreamPlayer.new()
	add_child(menu_music)
	# ใช้เพลงเดียวกับ MainFloor
	var music_file = load("res://Art/Audio/corridorsOgg.ogg")
	if music_file:
		menu_music.stream = music_file
		menu_music.volume_db = -5.0
		# ลองใส่ bus ถ้ามี ถ้าไม่มีก็เล่น Master แทน
		var music_index = AudioServer.get_bus_index("Music")
		if music_index != -1:
			menu_music.bus = "Music"
		menu_music.play()
	else:
		print("ERROR: ไม่พบไฟล์เพลง corridorsOgg.ogg")

func _load_volume_settings():
	var sfx_index = AudioServer.get_bus_index("SFX")
	var music_index = AudioServer.get_bus_index("Music")

	if sfx_index != -1:
		var sfx_val = db_to_linear(AudioServer.get_bus_volume_db(sfx_index))
		sfx_slider.value = sfx_val
		sfx_label.text = str(int(sfx_val * 100)) + "%"
	else:
		sfx_slider.value = 1.0
		sfx_label.text = "100%"
		print("WARNING: ไม่พบ SFX bus")

	if music_index != -1:
		var music_val = db_to_linear(AudioServer.get_bus_volume_db(music_index))
		music_slider.value = music_val
		music_label.text = str(int(music_val * 100)) + "%"
	else:
		music_slider.value = 1.0
		music_label.text = "100%"
		print("WARNING: ไม่พบ Music bus")

func _on_start_pressed():
	AudioManager.play_sound(AudioManager.COIN_PICK, 0, -5)
	await get_tree().create_timer(0.15).timeout
	GameManager.heal_on_next_level = true
	GameManager.player_health = -1
	get_tree().change_scene_to_file("res://Scenes/Levels/MainLobbyFloor.tscn")

func _on_settings_pressed():
	AudioManager.play_sound(AudioManager.COIN_PICK, 0, -5)
	settings_panel.visible = !settings_panel.visible

func _on_close_pressed():
	AudioManager.play_sound(AudioManager.COIN_PICK, 0, -5)
	settings_panel.visible = false

func _on_quit_pressed():
	AudioManager.play_sound(AudioManager.COIN_PICK, 0, -5)
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()

func _on_sfx_slider_changed(value: float):
	sfx_label.text = str(int(value * 100)) + "%"
	var safe_val = max(value, 0.001)
	var bus_index = AudioServer.get_bus_index("SFX")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(safe_val))
	else:
		# ถ้าไม่มี bus ให้ปรับ Master แทนชั่วคราว
		AudioServer.set_bus_volume_db(0, linear_to_db(safe_val))
	# เล่นเสียงให้รู้ว่า SFX ดังแค่ไหน
	AudioManager.play_sound(AudioManager.COIN_PICK, 0, linear_to_db(safe_val) - 10)

func _on_music_slider_changed(value: float):
	music_label.text = str(int(value * 100)) + "%"
	var safe_val = max(value, 0.001)
	var bus_index = AudioServer.get_bus_index("Music")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(safe_val))
	# ปรับเสียงเพลงเมนูทันที
	if is_instance_valid(menu_music):
		menu_music.volume_db = linear_to_db(safe_val) - 5.0
