class_name Player
extends CharacterBody3D


const BOMB = preload("uid://dgsfjbgrlgh3e")
enum BombState {
	NONE,
	HELD,
	}
@export var speed: float = 5.0
@export var deceleration_force: float = 1.0
var apply_gravity: bool = true
var can_move: bool = true
var mouse_free: bool = false
var _mouse_sens: float = 0.0
var _controller_sens: float = 0.0
var _bomb_state: BombState = BombState.NONE
var current_bomb: Bomb
@onready var mesh_pivot: Node3D = %MeshPivot
@onready var camera_arm: SpringArm3D = %CameraArm
@onready var camera_3d: Camera3D = %Camera3D
@onready var camera_pivot: Node3D = %CameraPivot
@onready var look_at_3d: LookAt3D = %LookAt3D
@onready var bomb_marker: Marker3D = %BombMarker


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GlobalSettings.sensitivity_changed.connect(_on_sensitivity_changed)
	_on_sensitivity_changed()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		_handle_input(event)
	
	if event is InputEventMouseMotion:
		if mouse_free:
			return
		camera_pivot.rotation.y -= event.relative.x * _mouse_sens


func _physics_process(delta: float) -> void:
	if apply_gravity:
		velocity += get_gravity() * 2.0 * delta
	else:
		velocity.y = 0

	if not can_move:
		move_and_slide()
		return
	
	var cam_axis: float = Input.get_axis(&"camera_left", &"camera_right")
	camera_pivot.rotation.y -= cam_axis * _controller_sens
	
	var input_dir := Input.get_vector(&"left", &"right", &"forward", &"backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).rotated(Vector3.UP, camera_pivot.rotation.y)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration_force)
		velocity.z = move_toward(velocity.z, 0, deceleration_force)
	move_and_slide()

	if direction and not is_on_wall():
		var look_dir: Vector3 = global_position + velocity
		look_dir.y = global_position.y
		look_at_3d.look_toward(look_dir)


func is_moving() -> bool:
	if Input.get_vector(&"left", &"right", &"forward", &"backward") != Vector2.ZERO:
		return true
	return false


func _handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_quit"):
		get_tree().quit()
	if event.is_action_pressed(&"spawn_bomb"):
		_spawn_bomb()
	if event.is_action_pressed(&"place_bomb"):
		_place_bomb()
	if event.is_action_pressed(&"throw_bomb"):
		_throw_bomb()


func _spawn_bomb() -> void:
	if not _bomb_state == BombState.NONE:
		return
	current_bomb = BOMB.instantiate()
	bomb_marker.add_child(current_bomb)
	_bomb_state = BombState.HELD
	


func _place_bomb() -> void:
	if not _bomb_state == BombState.HELD:
		return
	current_bomb.fuse_timer.start()
	current_bomb.reparent(get_tree().root)
	current_bomb.global_position = global_position + (mesh_pivot.basis * Vector3.FORWARD)
	_bomb_state = BombState.NONE


func _throw_bomb() -> void:
	if not _bomb_state == BombState.HELD:
		return
	current_bomb.fuse_timer.start()
	current_bomb.reparent(get_tree().root)
	current_bomb.apply_impulse(((mesh_pivot.basis * Vector3.FORWARD) + Vector3.UP) * 4)
	_bomb_state = BombState.NONE


func _on_sensitivity_changed() -> void:
	_mouse_sens = GlobalSettings.get_mouse_sens()
	_controller_sens = GlobalSettings.get_controller_sens()
