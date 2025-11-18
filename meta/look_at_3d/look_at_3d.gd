class_name LookAt3D
extends Node3D


@export var smooth_target: Node3D
@export var look_target: Node3D
@export var smooth: bool = true
@export var smoothing: float = 1.0
@onready var snap_look: Node3D = %SnapLook


func _process(delta: float) -> void:
	if not smooth_target:
		return
	if smooth:
		if look_target:
			snap_look.look_at(look_target.global_position)
		smooth_target.global_rotation.y = lerp_angle(
			smooth_target.global_rotation.y,
			snap_look.global_rotation.y,
			smoothing * delta
		)
		return
	smooth_target.look_at(look_target.global_position)


func look_toward(rot: Vector3) -> void:
	if rot == Vector3.ZERO:
		return
	snap_look.look_at(rot)
