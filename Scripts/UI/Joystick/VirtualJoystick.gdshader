shader_type canvas_item;

void fragment() {
    vec2 uv = UV * 2.0 - 1.0;
    float dist = length(uv);
    float alpha = 1.0 - smoothstep(0.98, 1.0, dist);

    COLOR = vec4(COLOR.rgb, COLOR.a * alpha);
}