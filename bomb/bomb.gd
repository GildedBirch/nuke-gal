class_name Bomb
extends RigidBody3D


const EXPLOSION_AUDIO: Array[AudioStreamWAV] = [
	preload("uid://dwwhg36dd11b0"),
	preload("uid://be4hcif6wb1bq"),
	preload("uid://31a7xstnolso"),
]
@onready var fuse_timer: Timer = %FuseTimer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = %AudioStreamPlayer3D
@onready var hit_area: Area3D = %HitArea


func _ready() -> void:
	fuse_timer.timeout.connect(_on_fuse_timeout)


func blow_up() -> void:
	freeze = true
	animation_player.play(&"explode")
	audio_player.stream = EXPLOSION_AUDIO.pick_random()
	audio_player.play()
	SignalBus.bomb.exploded.emit()
	await animation_player.animation_finished
	queue_free()


func _on_fuse_timeout() -> void:
	blow_up()
