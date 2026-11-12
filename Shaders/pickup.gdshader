shader_type canvas_item;

// Spritesheet layout: one row, every frame the same size.
// Each currency owns a block of `frames_per_animation` columns:
//   sprite_index 0 (Gear) -> columns 0-3,  sprite_index 1 (Star) -> columns 4-7
uniform int total_columns = 8;
uniform int frames_per_animation = 4;
uniform float animation_fps = 8.0;

// Per-instance data written by pickup_multimesh.gd:
//   INSTANCE_CUSTOM.r = random speed multiplier (0.9 - 1.1)
//   INSTANCE_CUSTOM.g = random starting frame offset (0 - 3)
//   INSTANCE_CUSTOM.b = sprite_index (the currency)
varying vec4 instance_tint;
varying vec3 pickup_custom;

void vertex() {
	instance_tint = COLOR;
	pickup_custom = INSTANCE_CUSTOM.rgb;
}

void fragment() {
	float speed = pickup_custom.r;
	float frame_offset = floor(pickup_custom.g + 0.5);
	float currency = floor(pickup_custom.b + 0.5);

	float step_count = floor(TIME * animation_fps * speed + frame_offset);
	float frame = mod(step_count, float(frames_per_animation));
	float column = currency * float(frames_per_animation) + frame;

	vec2 uv = vec2((UV.x + column) / float(total_columns), UV.y);
	COLOR = instance_tint * texture(TEXTURE, uv);
}
