class_name Enemy
extends CharacterBody3D


@export var stop_1: Marker3D
@export var stop_2: Marker3D
@export var speed: float = 3.0
var is_navigating: bool = false
var _is_stop_1: bool = true
@onready var nav_agent: NavigationAgent3D = %NavigationAgent3D
@onready var bomb_target_component: BombTargetComponent = %BombTargetComponent


func _ready() -> void:
	bomb_target_component.got_hit.connect(_got_hit)
	nav_agent.navigation_finished.connect(_on_nav_target_reached)
	nav_agent.velocity_computed.connect(_on_nav_velocity_computed)
	update_target_location(stop_1.global_position)


func _physics_process(delta: float) -> void:
	if not is_navigating:
		return
	var current_location: Vector3 = global_position
	var next_location: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = (next_location - current_location).normalized() * speed
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
