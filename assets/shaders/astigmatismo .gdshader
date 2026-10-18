
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform vec2 screen_resolution = vec2(1920.0, 1080.0);
uniform vec2 stretch_direction = vec2(0.0, 1.0);

uniform float blur_pixels : hint_range(0.0, 5.0) = 1.2;
uniform float streak_length : hint_range(1.0, 40.0) = 12.0;
uniform float blur_strength : hint_range(0.0, 1.0) = 0.22;
uniform float streak_strength : hint_range(0.0, 1.0) = 0.75;
uniform float light_threshold : hint_range(0.0, 1.0) = 0.58;
uniform float light_softness : hint_range(0.01, 0.5) = 0.15;

float luminance(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

vec4 sample_screen(vec2 uv) {
    return texture(screen_texture, clamp(uv, vec2(0.001), vec2(0.999)));
}

vec4 directional_blur(vec2 uv, vec2 axis, float radius) {
    vec2 pixel_size = vec2(
        1.0 / screen_resolution.x,
        1.0 / screen_resolution.y
    );

    vec2 offset = pixel_size * axis * radius;

    vec4 result = sample_screen(uv) * 0.28;
    result += sample_screen(uv + offset) * 0.22;
    result += sample_screen(uv - offset) * 0.22;
    result += sample_screen(uv + offset * 2.0) * 0.14;
    result += sample_screen(uv - offset * 2.0) * 0.14;

    return result;
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 axis = normalize(stretch_direction);

    vec4 original = sample_screen(uv);
    vec4 softened = directional_blur(uv, axis, blur_pixels);
    vec4 color = mix(original, softened, blur_strength);

    vec4 streak = directional_blur(uv, axis, streak_length);
    float brightness = luminance(streak.rgb);

    float mask = smoothstep(
        light_threshold,
        light_threshold + light_softness,
        brightness
    );

    color.rgb = mix(
        color.rgb,
        streak.rgb,
        mask * streak_strength
    );

    COLOR = color;
}
