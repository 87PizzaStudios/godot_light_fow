shader_type canvas_item;

uniform sampler2D fog_texture: filter_nearest, repeat_enable;
uniform sampler2D mask_texture: filter_nearest;
uniform vec2 fog_scroll_velocity = vec2(0.1, 0.1);


void fragment() {
	vec4 fog_color = textureLod(fog_texture,
		UV  + fog_scroll_velocity * TIME, 0.0);
	vec4 mask_color = textureLod(mask_texture, UV, 0.0);
	
	COLOR.rgb = fog_color.rgb;
	COLOR.a = min(fog_color.a, mask_color.a);
}
