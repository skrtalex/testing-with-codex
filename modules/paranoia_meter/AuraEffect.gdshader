shader_type canvas_item;

uniform float level : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    float dist = distance(uv, vec2(0.5));
    float alpha = smoothstep(0.45, 0.0, dist) * level;
    vec3 color = mix(vec3(0.8), vec3(0.2), level);
    COLOR = vec4(color, alpha);
}
