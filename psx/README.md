# PSX look

The retro look for Moonlight, layered on COGITO 1.2 (Godot 4.6).

## What's here

- `psx_screen.gdshader` and `psx_screen_layer.tscn`: a full screen pass that pixelates the 3D view to 480x270, cuts the colour to 15 bit and adds PS1 style ordered dither. The project loads it as the `PSXScreen` autoload, on canvas layer -1, so it affects only the 3D world. COGITO's HUD and menus stay crisp.
- `psx_surface.gdshader`: a material for meshes that adds vertex wobble, affine texture warping, per vertex lighting and nearest neighbour textures. Nothing uses it yet. COGITO's demo props keep their standard materials.

## Using the surface shader

1. Create a ShaderMaterial and pick `res://psx/psx_surface.gdshader`.
2. Set `albedo_texture`, and set the texture's import filter to Nearest.
3. Assign the material as the mesh's Material Override.

## Tuning (all guesses, push them where it feels right)

| Setting | Where | Default | Notes |
|---|---|---|---|
| `target_resolution` | PSXScreen material | 480x270 | 320x240 is real PS1 and closer to King's Field. |
| `color_levels` | PSXScreen material | 32 | Around 16 gives a grimier palette. |
| `enabled` | PSXScreen material | on | Turn it off to compare with the clean render. |
| `affine_strength` | surface material | 1.0 | 0.5 softens the warping on floors. |
| `snap_resolution` | surface material | 320x240 | Raise it to calm the wobble. |

## Dungeon darkness

A tight, foggy draw distance is most of the King's Field feel. In your level's WorldEnvironment:

- Use a black background.
- Turn on dense, near black fog.
- Keep ambient light low.
- Set the player Camera3D's Far to somewhere between 40 and 60.
