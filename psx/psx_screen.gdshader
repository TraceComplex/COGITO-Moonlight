// PSX style full screen pass for Godot 4.4+ (written for 4.6, COGITO 1.2).
// Runs on the 3D image only (it sits on canvas layer -1, under COGITO's HUD):
//   - pixelates to a low internal resolution (nearest neighbour)
//   - reduces colour depth (PS1 used 15-bit colour, 32 levels per channel)
//   - adds 4x4 ordered (Bayer) dithering, like the PS1's hardware dither
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform bool enabled = true;
// Internal resolution the 3D view is pixelated to.
// GUESS: 480x270 (16:9). Real PS1 is 320x240.
uniform vec2 target_resolution = vec2(480.0, 270.0);
// Levels per colour channel. 32 = PS1. Lower is moodier and more banded.
uniform float color_levels : hint_range(2.0, 256.0) = 32.0;
uniform float dither_strength : hint_range(0.0, 2.0) = 1.0;

const float BAYER[16] = float[](
	0.0,  8.0,  2.0, 10.0,
	12.0, 4.0, 14.0,  6.0,
	3.0, 11.0,  1.0,  9.0,
	15.0, 7.0, 13.0,  5.0
);

void fragment() {
	if (!enabled) {
		COLOR = texture(screen_texture, SCREEN_UV);
	} else {
		vec2 cell = floor(SCREEN_UV * target_resolution);
		vec2 uv = (cell + 0.5) / target_resolution;
		vec3 col = texture(screen_texture, uv).rgb;

		ivec2 p = ivec2(mod(cell, 4.0));
		float threshold = BAYER[p.y * 4 + p.x] / 16.0 - 0.5;
		float steps = color_levels - 1.0;
		col += threshold * dither_strength / steps;
		col = floor(col * steps + 0.5) / steps;
		COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
	}
}
