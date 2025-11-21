class_name Bomb
extends RigidBody3D


@onready var fuse_timer: Timer = %FuseTimer
@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	fuse_timer.timeout.connect(_on_fuse_timeout)


func _on_fuse_timeout() -> void:
	animation_player.play(&"explode")
	await animation_player.animation_finished
	queue_free()
