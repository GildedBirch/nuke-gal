extends Node


var bomb: BombSignals = BombSignals.new()
var machine: MachineSignals = MachineSignals.new()


@warning_ignore_start("unused_signal")
class BombSignals:
	signal exploded


class MachineSignals:
	signal destroyed
