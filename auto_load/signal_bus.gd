extends Node


var bomb: BombSignals = BombSignals.new()


@warning_ignore_start("unused_signal")
class BombSignals:
	signal exploded
