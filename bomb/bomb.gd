class_name Bomb
extends RigidBody3D


@onready var fuse_timer: Timer = %FuseTimer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = %AudioStreamPlayer3D
const EXPLOSION_AUDIO: Array[AudioStreamWAV] = [
	preload("uid://dwwhg36dd11b0"),
	preload("uid://be4hcif6wb1bq"),
	preload("uid://31a7xstnolso"),
]


func _ready() -> void:
	fuse_timer.timeout.connect(_on_fuse_timeout)


func _on_fuse_timeout() -> void:
	freeze = true
	animation_player.play(&"explode")
	audio_player.stream = EXPLOSION_AUDIO.pick_random()
	audio_player.play()
	await animation_player.animation_finished
	queue_free()
