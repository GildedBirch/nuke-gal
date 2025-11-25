class_name Bullet
extends Area3D


const SPEED: float = 10.0
@onready var timer: Timer = %Timer


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	timer.timeout.connect(_on_timeout)

func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta


func _on_area_entered(area: Area3D) -> void:
	area.hit(1)


func _on_timeout() -> void:
	queue_free() 
