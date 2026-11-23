// PSX style surface shader for Godot 4.4+ (written for 4.6, COGITO 1.2).
// Gives meshes the three classic PS1 tells:
//   1. Vertex snapping (the "wobbly" jitter as the camera moves)
//   2. Affine texture mapping (textures warp on big polygons up close)
//   3. Per-vertex (Gouraud) lighting and nearest-neighbour textures
//
// Use: make a ShaderMaterial with this shader on any MeshInstance3D,
// then set albedo_texture to the mesh's texture.
shader_type spatial;
render_mode vertex_lighting, specular_disabled, diffuse_lambert, cull_back;

uniform vec4 albedo_color : source_color = vec4(1.0);
uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_enable;
uniform vec2 uv_scale = vec2(1.0);

// Grid that vertices snap to, in screen pixels. Lower = more wobble.
// GUESS: 320x240 is real PS1 jitter. Lunacid feels closer to 480x270.
uniform vec2 snap_resolution = vec2(320.0, 240.0);
// 0 = normal perspective-correct textures, 1 = full PS1 affine warping.
uniform float affine_strength : hint_range(0.0, 1.0) = 1.0;
// Use vertex colours as baked light / tint (handy for hand-painted dungeon lighting).
uniform bool use_vertex_color = false;

varying vec2 affine_uv;
varying float affine_w;

void vertex() {
	UV = UV * uv_scale;
	vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	// Snap in normalised device coordinates, then go back to clip space.
	vec2 half_res = snap_resolution * 0.5;
	vec2 ndc = clip.xy / clip.w;
	ndc = round(ndc * half_res) / half_res;
	clip.xy = ndc * clip.w;
	POSITION = clip;

	// Interpolating UV*w and w, then dividing, cancels perspective correction.
	affine_uv = UV * clip.w;
	affine_w = clip.w;
}

void fragment() {
	vec2 uv = mix(UV, affine_uv / affine_w, affine_strength);
	vec4 tex = texture(albedo_texture, uv);
	vec3 col = tex.rgb * albedo_color.rgb;
	if (use_vertex_color) {
		col *= COLOR.rgb;
	}
	ALBEDO = col;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}
