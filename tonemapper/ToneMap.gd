"""
ToneMap.gd
@author Nicholas Hydock <nhydock@gmail.com>
@description |>
	Controls for palette cycling between screen space tonemaps
"""

extends ColorRect

export(Array) var palettes = []
var palette_idx = 0

func _input(event):
	if event.is_action_pressed("ui_palette_cycle"):
		palette_idx = wrapi(palette_idx + 1, 0, len(palettes))
		var palette = palettes[palette_idx]
		material.set_shader_param("tonemap", palette)
		accept_event()
