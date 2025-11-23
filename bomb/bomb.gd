class_name Bomb
extends RigidBody3D


enum Part {
	INNER,
	MIDDLE,
	OUTER,
	}
const EXPLOSION_AUDIO: Array[AudioStreamWAV] = [
	preload("uid://dwwhg36dd11b0"),
	preload("uid://be4hcif6wb1bq"),
	preload("uid://31a7xstnolso"),
]
var tier: int = 0
@onready var fuse_timer: Timer = %FuseTimer
@onready var explosion_outer: MeshInstance3D = %ExplosionOuter
@onready var explosion_middle: MeshInstance3D = %ExplosionMiddle
@onready var explosion_inner: MeshInstance3D = %ExplosionInner
@onready var hit_area: Area3D = %HitArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = %AudioStreamPlayer3D
@onready var hit_area_collision: CollisionShape3D = %HitAreaCollision


func _ready() -> void:
	fuse_timer.timeout.connect(_on_fuse_timeout)


func blow_up() -> void:
	freeze = true
	hit_area_collision.shape.radius *= _get_radius(Part.OUTER)
	animate()
	SignalBus.bomb.exploded.emit()
	await animation_player.animation_finished
	queue_free()


func animate() -> void:
	animation_player.play(&"explode")
	audio_player.stream = EXPLOSION_AUDIO.pick_random()
	audio_player.play()
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)
	# Outer
	tween.tween_property(explosion_outer, "mesh:radius", explosion_outer.mesh.radius * _get_radius(Part.OUTER), 1.0)
	tween.parallel().tween_property(explosion_outer, "mesh:height", explosion_outer.mesh.height * _get_radius(Part.OUTER), 1.0)
	# Middle
	tween.parallel().tween_property(explosion_middle, "mesh:radius", explosion_middle.mesh.radius * _get_radius(Part.MIDDLE), 1.0)
	tween.parallel().tween_property(explosion_middle, "mesh:height", explosion_middle.mesh.height * _get_radius(Part.MIDDLE), 1.0)
	#Inner
	tween.parallel().tween_property(explosion_inner, "mesh:radius", explosion_inner.mesh.radius * _get_radius(Part.INNER), 1.0)
	tween.parallel().tween_property(explosion_inner, "mesh:height", explosion_inner.mesh.height * _get_radius(Part.INNER), 1.0)


func _get_radius(part: Part) -> float:
	var tier_modifier: float = 0
	var part_modifier: float = 0
	match part:
		Part.INNER:
			part_modifier = 1.0
		Part.MIDDLE:
			part_modifier = 1.5
		Part.OUTER:
			part_modifier = 2.0
	
	match tier:
		0:
			tier_modifier = 1.5
		1:
			tier_modifier = 2.25
		2:
			tier_modifier = 4.0
	return tier_modifier * part_modifier


func _on_fuse_timeout() -> void:
	blow_up()
