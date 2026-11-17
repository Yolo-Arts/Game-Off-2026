shader_type canvas_item;

// This gives us access to the screen's current pixels
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
// This allows you to drop a GradientTexture1D into the Inspector
uniform sampler2D gradient_map : source_color;

uniform float intensity = 1.0;

void fragment() {
    // 1. Get the original color from the screen
    vec4 color = texture(screen_texture, SCREEN_UV);
    
    // 2. Invert the colors
    vec3 inverted = 1.0 - color.rgb;
    
    // 3. Convert to Grayscale
    // We use the "Luminance" weights for a more natural look
    float gray = dot(inverted, vec3(0.299, 0.587, 0.114));
    
    // 4. Map the Gradient
    // We use the grayscale value (0.0 to 1.0) as the X coordinate for the gradient
    vec4 mapped_color = texture(gradient_map, vec2(gray, 0.0));
    
    COLOR = vec4(mix(mapped_color.rgb, color.rgb, 1.0 - intensity), color.a);
}