shader_type canvas_item;

uniform sampler2D light_texture: filter_nearest;
uniform sampler2D mask_texture: filter_nearest;

void fragment() {
	vec4 mask_color = textureLod(mask_texture, SCREEN_UV, 0.0);
	// use luminosity to set transparency
	vec4 light_color = textureLod(light_texture, SCREEN_UV, 0.0);
	float lumen = 0.2126 * light_color.r + 0.7152 * light_color.g + 0.0722 * light_color.b;
	float light_alpha = clamp(1.-lumen, 0., 1.);
	float alpha = min(mask_color.a, light_alpha);
	
	COLOR = vec4(vec3(0.0), alpha);
}