"""
ToneMapper.gd
@author Nicholas Hydock <nhydock@gmail.com>
@description |>
	Controls for palette cycling between screen space tonemaps
"""

extends Control

export(Array) var palettes = []
export(Vector2) var resolution = Vector2(320,240)
export var palette_idx = 0
onready var color_rect = get_node("CanvasLayer/BackBufferCopy/ColorRect") as ColorRect
onready var buffer = get_node("CanvasLayer/BackBufferCopy") as BackBufferCopy

func _ready():
	buffer.rect = Rect2(Vector2(0,0), resolution)
	color_rect.material.set_shader_param("tonemap", palettes[palette_idx])

func _input(event):
	if event.is_action_pressed("ui_palette_cycle"):
		palette_idx = wrapi(palette_idx + 1, 0, len(palettes))
		var palette = palettes[palette_idx]
		color_rect.material.set_shader_param("tonemap", palette)
		accept_event()
