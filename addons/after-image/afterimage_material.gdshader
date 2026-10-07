shader_type spatial;
render_mode depth_draw_always, cull_disabled, unshaded, blend_add;

uniform sampler2D albedo_texture: filter_nearest, source_color;
instance uniform vec2 uv_offset = vec2(0.0);

const vec3 ign = vec3(0.06711056f, 0.00583715f, 52.9829189f);

void fragment() {
	vec2 uv = UV + uv_offset;
	vec3 color = vec3(1.0, 0.07, 0.14);
	ALBEDO = color;
	float alpha = texture(albedo_texture, uv).a;
	if (alpha < 1.0) {
		discard;
	}
		
	ALBEDO = color;
	//ALPHA = 0.3 * ALPHA;
}

void light() {
	DIFFUSE_LIGHT += step(0.001, ATTENUATION) * LIGHT_COLOR; 
}