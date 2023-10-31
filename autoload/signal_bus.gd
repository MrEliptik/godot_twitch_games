extends Node

signal transparency_toggled(transparent: bool)

func emit_transparency_toggled(transparent: bool) -> void:
	transparency_toggled.emit(transparent)
