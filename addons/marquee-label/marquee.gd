"""
marquee.gd
@author erodozer <ero@erodozer.moe>

Horizontally scrolling Text Control like classic HTML Marquees.

Note: This component does not inherit from Label, as it uses a custom draw function.
"""
extends Control
class_name MarqueeLabel

@export var scroll_speed: int = 10
@export var text: String = ""
@export var label_settings: LabelSettings
		
var scroll_offset: float = 0
			
func bounding_width() -> int:
	var f = label_settings.font
	var s = label_settings.font_size
			
	return max(1, f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, s).x)

func _draw():
	var f = label_settings.font
	var s = label_settings.font_size
	var w = bounding_width()
	var right = get_rect().size.x
	var x = -w + scroll_offset
	while x < right:
		draw_string(f, Vector2(x, f.get_height(s)), text, HORIZONTAL_ALIGNMENT_LEFT, -1, s)
		x += w

func _process(delta):
	scroll_offset += float(scroll_speed) * delta
	if scroll_offset > bounding_width():
		scroll_offset = 0
	queue_redraw()
