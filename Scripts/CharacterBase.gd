# Scripts/CharacterBase.gd
# แก้ไขจากเดิม: เพิ่ม _heal() และ init_character รองรับ HP ข้ามด่าน
extends CharacterBody2D
class_name CharacterBase

@export var sprite : AnimatedSprite2D
@export var healthbar : ProgressBar
@export var health : int
@export var flipped_horizontal : bool
@export var hit_particles : GPUParticles2D
var invincible : bool = false
var is_dead : bool = false

func _ready():
	init_character()

func _process(_delta):
	Turn()

func init_character():
	healthbar.max_value = health
	
	if is_in_group("Player"):
		if GameManager.heal_on_next_level or GameManager.player_health <= 0:
			healthbar.value = health
			GameManager.player_health = health
		else:
			health = GameManager.player_health
			healthbar.value = health
		
		GameManager.heal_on_next_level = false
	else:
		healthbar.value = health

func Turn():
	var direction = -1 if flipped_horizontal == true else 1
	if(velocity.x < 0):
		sprite.scale.x = -direction
	elif(velocity.x > 0):
		sprite.scale.x = direction

# Heal จากเก็บ coin (เรียกจาก CoinPickup.gd)
func _heal(amount : int):
	if is_dead:
		return
	health = clampi(health + amount, 0, int(healthbar.max_value))
	healthbar.value = health
	GameManager.player_health = health

#region Taking Damage
func damage_effects():
	AudioManager.play_sound(AudioManager.BLOODY_HIT, 0, -3)
	after_damage_iframes()
	if(hit_particles):
		hit_particles.emitting = true

func after_damage_iframes():
	invincible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.DARK_RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	await tween.finished
	invincible = false

func _take_damage(amount):
	if(invincible == true || is_dead == true):
		return
	health -= amount
	healthbar.value = health
	GameManager.player_health = health   # บันทึก HP ทุกครั้งที่โดนตี
	damage_effects()
	if(health <= 0):
		_die()

func _die():
	if(is_dead):
		return
	is_dead = true
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(self) and not is_in_group("Player"):
		queue_free()
#endregion
