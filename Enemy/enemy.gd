class_name Enemy
extends CharacterBody3D


@export var stop_1: Marker3D
@export var stop_2: Marker3D
@export var speed: float = 3.0
var is_navigating: bool = false
var _is_stop_1: bool = true
@onready var nav_agent: NavigationAgent3D = %NavigationAgent3D
@onready var bomb_target_component: BombTargetComponent = %BombTargetComponent
@onready var player_detector: Area3D = %PlayerDetector
@onready var timer: Timer = %Timer
@onready var mesh_pivot: Node3D = %MeshPivot


func _ready() -> void:
	bomb_target_component.got_hit.connect(_got_hit)
	nav_agent.navigation_finished.connect(_on_nav_target_reached)
	nav_agent.velocity_computed.connect(_on_nav_velocity_computed)
	timer.timeout.connect(_on_timeout)
	update_target_location(stop_1.global_position)


func _physics_process(delta: float) -> void:
	if not is_navigating:
		return
	var current_location: Vector3 = global_position
	var next_location: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = Vector3.ZERO
	new_velocity.x = (next_location - current_location).normalized().x * speed
	new_velocity.z = (next_location - current_location).normalized().z * speed
	nav_agent.velocity += get_gravity() * 2.0 * delta
	nav_agent.velocity = new_velocity


func update_target_location(target_location: Vector3) -> void:
	nav_agent.target_position = target_location
	is_navigating = true


func _on_nav_velocity_computed(safe_velocity: Vector3):
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()


func _on_nav_target_reached() -> void:
	is_navigating = false
	if _is_stop_1:
		_is_stop_1 = false
		update_target_location(stop_2.global_position)
	else:
		_is_stop_1 = true
		update_target_location(stop_1.global_position)


func _got_hit(_damage: int) -> void:
	queue_free()


func _on_timeout() -> void:
	var players: Array[Node3D] = player_detector.get_overlapping_bodies()
	for p in players:
		print(p.name)
	if not players:
		return
	#print("a")
	mesh_pivot.look_at(players[0].global_position)
