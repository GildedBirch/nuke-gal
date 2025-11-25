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
# Bomb variables
var _bomb_state: BombState = BombState.NONE
var _current_bomb: Bomb
var _total_bombs: int = 1
var _current_bombs: int = 0
var _radius_tier: int = 0
var _damage_tier: int = 0
var _machines_destroyed: int = 0
# Refs
@onready var mesh_pivot: Node3D = %MeshPivot
@onready var camera_arm: SpringArm3D = %CameraArm
@onready var camera_3d: Camera3D = %Camera3D
@onready var camera_pivot: Node3D = %CameraPivot
@onready var look_at_3d: LookAt3D = %LookAt3D
@onready var bomb_marker: Marker3D = %BombMarker
@onready var bomb_target_component: BombTargetComponent = %BombTargetComponent


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GlobalSettings.sensitivity_changed.connect(_on_sensitivity_changed)
	SignalBus.bomb.exploded.connect(_on_bomb_exploded)
	SignalBus.machine.destroyed.connect(_on_machine_destroyed)
	bomb_target_component.got_hit.connect(func(_d: int): get_tree().reload_current_scene())
	_on_sensitivity_changed()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
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
		if look_dir == global_position:
			return
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
	if _current_bombs >= _total_bombs:
		return
	_current_bombs += 1
	_current_bomb = BOMB.instantiate()
	bomb_marker.add_child(_current_bomb)
	_current_bomb.radius_tier = _radius_tier
	_current_bomb.damage_tier = _damage_tier
	_bomb_state = BombState.HELD


func _place_bomb() -> void:
	if not _bomb_state == BombState.HELD:
		return
	_current_bomb.fuse_timer.start()
	_current_bomb.reparent(get_tree().root)
	_current_bomb.global_position = global_position + (mesh_pivot.basis * Vector3.FORWARD)
	_bomb_state = BombState.NONE
	_current_bomb = null


func _throw_bomb() -> void:
	if not _bomb_state == BombState.HELD:
		return
	_current_bomb.fuse_timer.start()
	_current_bomb.reparent(get_tree().root)
	var throw_force: Vector3 = ((mesh_pivot.basis * Vector3.FORWARD) + Vector3.UP) + velocity.normalized()
	_current_bomb.apply_impulse(throw_force * 4)
	_bomb_state = BombState.NONE
	_current_bomb = null


func _on_bomb_exploded() -> void:
	_current_bombs = maxi(_current_bombs - 1, 0)


func _on_machine_destroyed() -> void:
	_machines_destroyed += 1
	if _machines_destroyed % 2 == 0:
		if _radius_tier < 2:
			_radius_tier += 1
	else:
		_total_bombs += 1


func _on_sensitivity_changed() -> void:
	_mouse_sens = GlobalSettings.get_mouse_sens()
	_controller_sens = GlobalSettings.get_controller_sens()
