shader_type canvas_item;
render_mode blend_mix;

uniform float blur: hint_range(0.0, 5.);
uniform float brightness: hint_range(0.0, 1.0);

vec4 bluring2(sampler2D tex, vec2 uv, vec2 ps) {
	vec4 col = texture(tex, uv);
	col += texture(tex, uv + vec2(0.0, -blur) * ps);
	col += texture(tex, uv + vec2(0.0, blur) * ps);
	col += texture(tex, uv + vec2(-blur, 0.0) * ps);
	col += texture(tex, uv + vec2(blur, 0.0) * ps);
	col /= 5.0;
	return col;
}

void fragment() {
	COLOR = bluring2(SCREEN_TEXTURE, SCREEN_UV, SCREEN_PIXEL_SIZE);
	COLOR.rgb *= brightness;
}
