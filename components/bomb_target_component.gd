class_name BombTargetComponent
extends Area3D


signal got_hit(damage: int)


func hit(damage: int) -> void:
	print(damage)
	got_hit.emit(damage)
