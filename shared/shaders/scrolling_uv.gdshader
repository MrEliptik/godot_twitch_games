shader_type canvas_item;

uniform vec2 scroll_dir = vec2(1.0, 0.0);
uniform float scroll_speed = 1.0;
uniform vec4 color: source_color;

void fragment() {
	vec2 moving_uv = UV + (TIME * scroll_dir * scroll_speed);
	vec4 in_tex = texture(TEXTURE, moving_uv);
	
	COLOR.rgb = in_tex.rgb * color.rgb;
	COLOR.a = in_tex.a;
}
