class_name Machine
extends Node3D


@onready var machine: MeshInstance3D = %Machine
@onready var machine_broken: MeshInstance3D = %Machine_Broken
@onready var bomb_target_component: BombTargetComponent = %BombTargetComponent
@onready var audio_stream_player_3d: AudioStreamPlayer3D = %AudioStreamPlayer3D


func _ready() -> void:
	bomb_target_component.got_hit.connect(_on_got_hit)


func _on_got_hit(_damage: int) -> void:
	machine.hide()
	machine_broken.show()
	audio_stream_player_3d.play()
	bomb_target_component.queue_free()
	SignalBus.machine.destroyed.emit()
