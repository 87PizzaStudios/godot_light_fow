shader_type canvas_item;
uniform sampler2D fog_texture: filter_nearest;
uniform sampler2D mask_texture: filter_nearest;

void fragment() {
	vec4 fog_color = textureLod(fog_texture, SCREEN_UV, 0.0);
	vec4 mask_color = textureLod(mask_texture, SCREEN_UV, 0.0);
	
	COLOR.rgb = fog_color.rgb;
	COLOR.a = mask_color.a;
}
