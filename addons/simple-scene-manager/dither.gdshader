shader_type canvas_item;
render_mode blend_mix;

uniform vec4 clear_color = vec4(0,0,0,1);

float val(vec3 color) {
	return max(min(max(max(color.r, color.g), color.b), 1.0), 0.001);
}

float lum(vec4 color) {
	return dot(color.rgb, vec3(0.2126,0.7152,0.0722));
}

void fragment() {
	vec4 sample = texture(TEXTURE, UV.xy);
	if (val(sample.rgb) <= COLOR.a) {
		COLOR = clear_color;
	} else {
		COLOR = vec4(0,0,0,0);
	}
}
