shader_type canvas_item;

uniform float level : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5);
    float dist = distance(uv, center);
    float glow = smoothstep(0.2, 0.5, dist) * level;

    vec3 col;
    if (level < 0.25) {
        col = vec3(0.75); // light gray
    } else if (level < 0.5) {
        col = vec3(0.5); // medium gray
    } else if (level < 0.75) {
        col = vec3(0.25); // dark gray
    } else {
        float flicker = sin(TIME * 20.0) * 0.05;
        col = vec3(0.1 + flicker); // darkest with flicker
    }
    COLOR = vec4(col * glow, glow);
}
