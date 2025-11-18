extends Node


signal sensitivity_changed

const MOUSE_SENSITIVITY: float = 0.002
const CONTROLLER_SENSITIVITY: float = 0.05
var sensitivity: float = 1.0


func set_sensitivity(new_sens: float) -> void:
	sensitivity = new_sens
	sensitivity_changed.emit()


func get_mouse_sens() -> float:
	return MOUSE_SENSITIVITY * sensitivity


func get_controller_sens() -> float:
	return CONTROLLER_SENSITIVITY * sensitivity
