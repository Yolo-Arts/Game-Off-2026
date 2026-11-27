shader_type canvas_item;

uniform sampler2D gradient;

void fragment() {
	float x = (sin(UV.x + TIME) + 1.0) * 0.5;
	vec4 c = texture(gradient, vec2(x, 0.0));
	COLOR = c;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
