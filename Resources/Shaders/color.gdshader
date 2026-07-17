shader_type canvas_item;

uniform vec4 color: source_color;
uniform float quantity: hint_range(0.0, 1.0, 0.1) = 0.0;

void fragment() {
	vec4 tx = texture(TEXTURE, UV);
	COLOR.rgb = mix(tx, color, quantity).rgb;
}

