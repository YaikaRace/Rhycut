shader_type canvas_item;

uniform vec4 col: source_color;
uniform vec4 color: source_color;
uniform float quantity: hint_range(0.0, 1.0, 0.1) = 0.0;

void fragment() {
	float size_x = 1.0/float(textureSize(TEXTURE, 0).x);
	float size_y = 1.0/float(textureSize(TEXTURE, 0).y);
	vec4 sprite_color = texture(TEXTURE, UV);
	float alpha = -4.0 * sprite_color.a;
	alpha += texture(TEXTURE, UV + vec2(size_x, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(-size_x, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(0, size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(0, -size_y)).a;
	vec4 final_col = mix(sprite_color, col, clamp(alpha, 0.0, 1.0));
	COLOR = final_col;
	COLOR.rgb = mix(final_col, color, quantity).rgb;
}
