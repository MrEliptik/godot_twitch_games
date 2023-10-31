extends Node

signal transparency_toggled(value: bool)


func emit_transparency_toggled(value: bool) -> void:
	transparency_toggled.emit(value)
