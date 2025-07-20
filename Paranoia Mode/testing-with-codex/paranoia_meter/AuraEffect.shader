shader_type canvas_item;

void fragment() {
    vec2 uv = UV;
    float vignette = smoothstep(0.8, 0.4, distance(uv, vec2(0.5)));
    COLOR = mix(texture(TEXTURE, uv), vec4(0.0, 0.0, 0.0, 0.7), vignette);
}
