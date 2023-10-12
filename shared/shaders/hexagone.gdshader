shader_type canvas_item;
uniform sampler2D gradient_map: source_color;
uniform vec2 scale = vec2(100, 100);
uniform float speed_scale: hint_range(0.0, 10.0, 0.01) = 1.0;

float HexDist(vec2 p) {
	p = abs(p);
    
    float c = dot(p, normalize(vec2(1,1.73)));
    c = max(c, p.x);
    
    return c;
}

vec4 HexCoords(vec2 uv) {
	vec2 r = vec2(1, 1.73);
    vec2 h = r*.5;
    
    vec2 a = mod(uv, r)-h;
    vec2 b = mod(uv-h, r)-h;
    
    vec2 gv = dot(a, a) < dot(b,b) ? a : b;
    
    float x = atan(gv.x, gv.y);
    float y = .5-HexDist(gv);
    vec2 id = uv-gv;
    return vec4(x, y, id.x,id.y);
}

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}

float stripes(vec2 p, float s) {
	p *= s;
	float n = fract(p.x - p.y * 1.73);
	if (n > 0.75 || n < 0.25)
		return 0.5;
	return 0.25;
}

void fragment() {
	vec2 uv = UV * scale;
    uv *= 10.0;
    vec4 hc = HexCoords(uv / 500.0);
    
	int i = hc.y < 0.05 ? 0 : (hc.y > 0.15 ? 1 : 2);
	vec3 xcol1 = vec3(stripes(uv.xy, 0.005)) * noise(hc.zw / 3.0 + (TIME*speed_scale));
	vec3 xcol2 = vec3(0.375) * noise(hc.zw / 3.0 + (TIME*speed_scale) * -1.0);
    vec3 col = i == 0 ? vec3(0.125, 0.125, 0.125) : (i == 1 ? xcol1 : xcol2);

	vec3 in_gradient = texture(gradient_map, vec2(col.r, 0.0)).rgb;

    COLOR.rgb = mix(col, in_gradient, 1.0);
    COLOR.a = 1.0;
//    COLOR = vec4(col, 1.0);
}