# Organic Edge

Organic Edge is an independent desktop field, configured in **Settings → Widgets → Screen edges** or through the border icon in desktop edit mode. It renders behind desktop widgets and windows and never captures pointer input. Enabling the regular Visualizer is not required.

Choose one or more sides, or start from a complete scene. Scenes set composition, material, shape, light, color behavior and music response together while preserving enabled displays. Fine tuning stays live after a scene is applied. Adjust length, position, inward reach, screen inset, corner radius and reach per side. In **Join connected edges** mode, full-length adjacent sides share one corner field instead of drawing two competing crests; four selected sides behave as one continuous frame. **Keep edges separate** preserves independent rails. “Respect bars and dock” uses the current panel insets. Coordinates are logical pixels; reach is capped at 45% of the available axis to preserve the centre.

Material and shape are separate. Silk uses a translucent moving sheen; Aurora emphasizes luminous strands; Contour draws a fine crest; Liquid uses a fuller body. Flow keeps the original organic contour, Ribbon makes broad continuous waves, Pulse cells localize musical bulges, and Filament concentrates fine high-frequency motion. Adaptive color follows album artwork when a usable cover exists and falls back to the wallpaper-derived scheme; Wallpaper, Album, Theme, Vivid, Iridescent, monochrome, cool and warm remain explicit source/profile choices. Vivid/cool/warm transform semantic source colors instead of using fixed RGB palettes. Custom exposes three color pickers. Flow, Spectrum, Beat and Static define how color travels through the field; Clean, Shimmer, Echo, Prism, Bloom, Caustic and Afterglow change the light treatment without adding another renderer. Overall opacity, body opacity, crest brightness, glow intensity and glow spread are independent so light can grow without turning the field into a solid band.

Music response can be tuned separately from appearance. Smooth, Balanced, Punchy, Bass pulse and Fine detail response presets adjust the envelope without replacing the selected material or shape. Local live/peak energy now drives the contour in addition to the global envelope, so bass, mids, treble and transients deform different parts of the field instead of scaling the whole edge uniformly. Sensitivity and Audio range control deformation, Beat pulse controls geometric movement, Beat glow lights the crest and halo, Transient punch emphasizes attacks, and Bass drive/Treble shimmer split low-frequency movement from high-frequency light. Attack and Release tune how quickly the field catches and settles after a hit; smoothing and frequency separation remain available for finer control. Motion speed and ambient motion are integrated continuously, so live tuning changes velocity without resetting the phase used by either the screen edge or desktop Organic renderer. Ambient mode works without an audio subscription, and silent behavior can animate, settle into a still frame or fade away.

The field follows desktop widget power saving, GameMode and session locking. Global animation disable freezes motion. Disabled or suppressed fields release their renderer; audio capture uses the existing shared Cava subscription rather than a process per side.

## Implementation contract

- `OrganicEdgeWidget.qml` owns Config, output selection, panel-aware geometry, palette and lifecycle.
- `OrganicEdgeConfig.js` owns scenes, response presets, control metadata and fallback values. `Config.qml` and `defaults/config.json` declare persistence and fresh-install defaults.
- `OrganicAudioMotion.qml` owns audio normalization, twelve smoothed bands, decaying peaks, energy, pulse and the continuous animation clock. Both Organic renderers inherit it; motion tuning eases velocity without resetting phase, and it has no Config, Cava or screen dependency.
- `OrganicScreenEdge.qml` exposes the screen renderer's uniforms. `OrganicScreenEdge.frag` performs one direct scene-graph draw without a wallpaper texture, blur pass or offscreen framebuffer. Pixels beyond enabled edge reaches skip field evaluation. Connected corners use one radial corner field with single-pixel ownership; independent overlaps retain union blending. Color is weight-normalized and output is premultiplied.
- `OrganicAudioBlob.qml` retains the existing radial/media renderer API. Its shader is separate from the screen material.

Shader edges and depths use top/right/bottom/left order. Geometry is `(span, position, taper, cornerRadius)`, with ratios in 0–1 except logical-pixel corner radius. Depths are logical pixels. Material is `(restingThickness, detail, glow, styleIndex)`, with style indices Silk=0, Aurora=1, Contour=2, Liquid=3. Keep the GLSL uniform block and QML properties synchronized. Bake portable shader variants with:

```sh
/usr/lib/qt6/bin/qsb --qt6 -o modules/common/widgets/OrganicScreenEdge.frag.qsb modules/common/widgets/OrganicScreenEdge.frag
```

Persistence lives under `background.edgeWidgets.organic`. Empty `edges` preserves the legacy single `edge`; empty `screenList` means all displays. Presets and reset never change the enabled displays. The source and baked shader must ship together.

```sh
inir background organicEdgeState
inir background setOrganicEdgeEnabled true
inir background applyOrganicEdgePreset "Album Aura"
```
