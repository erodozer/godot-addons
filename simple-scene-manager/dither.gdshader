shader_type canvas_item;
render_mode blend_mix;

uniform float transition: hint_range(0, 1);

float val(vec3 color) {
	return max(max(color.r, color.g), color.b);
}

void fragment() {
	vec4 sample = texture(TEXTURE, UV.xy);
	if (val(sample.rgb) < transition) {
		COLOR = vec4(0,0,0,0);
	} else {
		COLOR = vec4(0,0,0,1);
	}
}