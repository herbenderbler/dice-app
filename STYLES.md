# Style Directions — UI & Haptics

Five candidate styles for the redesign on this branch. Shared requirements
for all five: the die is a full-bleed rounded card that nearly fills the
screen, corners use iOS continuous curvature, colors are soft pastels, and
every palette passes mathematically verified WCAG contrast gates — pips
>= 3:1 against the die face (all five exceed 7:1), hint text >= 4.5:1
against the background, accent >= 3:1 — in **both** light and dark mode.
Every style also specifies Reduce Motion behavior, an Increase Contrast
variant, and differentiates by lightness rather than hue (color-blind safe).

| # | Style | Mood | Corner radius | Haptic character |
|---|-------|------|--------------|------------------|
| 1 | Powder & Chalk | Scandinavian calm, chalk on slate | 40pt | One crisp tick on settle |
| 2 | Sorbet Sunset | Golden-hour dessert warmth | 48pt | Soft two-beat landing |
| 3 | Matcha Garden | Botanical, grounded, organic | 48pt | Single muted earthy thud |
| 4 | Lavender Haze | Dreamy dusk, floaty | 44pt | Feather-light fading sequence |
| 5 | Candy Pop | Playful, toy-like, bold | 56pt | Playful light-light-medium rhythm |

---

## 1. Powder & Chalk

Scandinavian minimalism as a physical material story: a sheet of warm chalk-white paper resting on a powder-blue field. The die is a full-bleed rounded card of chalk paper (16pt margins on all sides, hint text overlaid in the bottom margin area of the card's safe zone), with slate-blue pips pressed into it like ink stamps — flat, exact, generously spaced. Nothing decorates; the whole screen is one calm object. In dark mode the material story inverts honestly rather than dimming: the die becomes a slate chalkboard (#232F3C) and the pips become chalk (#CBDCEA) — literal chalk-on-slate — floating on a deep night-blue field. Both modes are a single monochrome slate-blue ramp plus one warm chalk neutral, so the design differentiates purely by lightness, never by hue.

### Palette

| Role | Light | Dark |
|------|-------|------|
| Background | `#CBDCEA` | `#141C26` |
| Background (secondary) | `#BDD1E2` | `#0F161E` |
| Die face | `#FBFAF6` | `#232F3C` |
| Die border | `#A9BFD2` | `#43566A` |
| Pips | `#3D5570` | `#CBDCEA` |
| Hint text | `#41586F` | `#9FB6CB` |
| Accent | `#537699` | `#8AA9C6` |

### Verified contrast (WCAG 2.x)

| Pair | Light | Dark | Gate |
|------|-------|------|------|
| pips vs dieFace | 7.36:1 | 9.7:1 | 3.0 |
| hintText vs background | 5.25:1 | 8.19:1 | 4.5 |
| accent vs background | 3.39:1 | 7:1 | 3.0 |
| hintText vs backgroundSecondary | 4.7:1 | 8.69:1 | 4.5 |
| dieFace vs background (informational) | 1.34:1 | 1.26:1 | — |

### Pips

Perfect circles (SwiftUI Circle in a custom Layout or GeometryReader grid), flat fill, zero gradients, shadows, or strokes — chalk pressed flat into paper. Pip diameter = 0.17 x die-card's shorter side; centers on the classic 3x3 grid at offsets of +/-0.26 x shorter side from the card center (so face 6 uses columns at +/-0.26, rows at -0.26/0/+0.26). Geometry is mathematically exact: no rotation, no jitter, no per-pip randomness — the personality is drafting-table precision with generous negative space. Pips animate in/out with opacity only (plus a 0.90 -> 1.00 scale on settle); they never move position. On the near-full-screen card (roughly 361pt wide on a 393pt iPhone with 16pt margins) pips land around 61pt diameter — large, unmistakable, legible from across a table.

### Animation

Small, exact, no overshoot — the die acknowledges rather than performs. Sequence on tap: (1) Press acknowledgment: die card scales 1.0 -> 0.985 with .snappy(duration: 0.18, extraBounce: 0). (2) Tumble: 4 intermediate faces flicker over ~0.44s, one tick every ~110ms, each face change an 80ms opacity crossfade; simultaneously the card rotates a restrained +/-1.2 degrees, alternating sign per tick (keyed off displayedFace as today), animated with .snappy(duration: 0.14, extraBounce: 0). (3) Settle: rotation returns to exactly 0, scale to exactly 1.0 via .snappy(duration: 0.22, extraBounce: 0); the result face's pips fade in over 140ms easeOut while scaling 0.90 -> 1.00. No spring bounce parameters above 0 anywhere. Reduce Motion: all scale and rotation removed and no flicker faces — a single 150ms opacity crossfade directly to the result face; the settle haptic and the existing AccessibilityNotification.Announcement("Rolled N") carry the event instead of motion.

### Haptics

Strictly one haptic event per roll: a single clean tick at the settle frame, synchronized with the final pips' fade-in (~0.44s after tap; immediately under Reduce Motion). No haptics during the flicker ticks and none on touch-down. SwiftUI implementation: .sensoryFeedback(.impact(weight: .light, intensity: 0.8), trigger: settledRollCount) where settledRollCount increments only when the final face lands (not when the roll starts — replaces the current trigger on rollCount which fires at roll start). CoreHaptics refinement (optional, for crispness beyond what impact offers): one transient CHHapticEvent with hapticIntensity 0.65 and hapticSharpness 0.9 at relative time 0, played from a pre-warmed CHHapticEngine at settle — the high sharpness / moderate intensity combination reads as a precise 'tick' rather than a thud. Respects system haptic settings automatically via sensoryFeedback; the CoreHaptics path should check CHHapticEngine.capabilitiesForHardware().supportsHaptics and fall back to the sensoryFeedback modifier.

### Design notes

All gates verified with WCAG 2.x relative luminance math. LIGHT: pips #3D5570 on dieFace #FBFAF6 = 7.36:1 (gate 3.0, aim 4.5 — exceeded); hintText #41586F on background #CBDCEA = 5.25:1 (gate 4.5; also 4.70:1 on backgroundSecondary #BDD1E2); accent #537699 on background = 3.39:1 (gate 3.0; 3.03:1 on backgroundSecondary). DARK: pips #CBDCEA on dieFace #232F3C = 9.70:1; hintText #9FB6CB on background #141C26 = 8.19:1; accent #8AA9C6 on background = 7.00:1. Die face vs background: dark = 1.26:1 (< 1.3, so dieBorder #43566A is required — 2.27:1 vs background, 1.80:1 vs face, drawn as a 1pt inset stroke); light = a borderline 1.34:1, so a hairline 1pt #A9BFD2 border is specified there too (1.82:1 vs the chalk face) to keep the card edge defined on washed-out or True Tone-shifted displays. Color-blind safety: the entire system is one slate-blue hue family plus a warm neutral — every functional pair (pips/face, text/background, accent/background) is separated by large lightness deltas, so deuteranopia, protanopia, and tritanopia all see the same hierarchy; hue carries zero information. Increase Contrast variant (verified): light mode deepens pips to #2C405A (10.11:1), hintText to #32475D (6.82:1), and thickens the die border to 2pt #64809B (3.94:1 vs face); dark mode brightens pips to #E4EDF5 (11.49:1), hintText to #C6D6E4 (11.55:1), border 2pt #64809B (4.17:1 vs background); backgroundSecondary flattens to equal background in both modes to remove decorative low-contrast variation. Reduce Motion behavior is specified in the animation field: crossfade-only, with the haptic tick and VoiceOver announcement as the non-visual settle signal. The dark palette is a true companion, not an inversion: the pastels desaturate and deepen into slate and night-blue while the chalk value migrates from the face to the pips, preserving the material logic (chalk on slate) instead of producing glowing pastels on black. cornerRadius 40pt with 16pt screen margins sits approximately concentric inside modern iPhone display corners (~55-56pt), which is what makes the full-bleed card read as 'precise' rather than merely rounded; use RoundedRectangle(cornerRadius: 40, style: .continuous) for iOS continuous curvature.


---

## 2. Sorbet Sunset

Golden-hour dessert warmth: a cream die card floating on a soft peach-to-apricot sky gradient, with pips and text in deep terracotta like espresso drizzled over sorbet. Light mode is a hazy late-afternoon glow; dark mode is the same scene after sundown — embers and cocoa, with the peach tones surviving as warm luminous pips and text on a deep toasted-brown card. Everything is round, plump, and buoyant: continuous-curvature corners, oversized soft pips, springy squash-and-stretch motion, and a gentle two-beat "landing" haptic like a die settling on felt.

### Palette

| Role | Light | Dark |
|------|-------|------|
| Background | `#FFE8D6` | `#251511` |
| Background (secondary) | `#FFD3BC` | `#361E15` |
| Die face | `#FFFBF2` | `#3E2620` |
| Die border | `#F3C4A6` | `#65402F` |
| Pips | `#83321B` | `#FFDFC2` |
| Hint text | `#8A4226` | `#F5C9A8` |
| Accent | `#B4472A` | `#FF9C78` |

### Verified contrast (WCAG 2.x)

| Pair | Light | Dark | Gate |
|------|-------|------|------|
| pips vs dieFace | 8.34:1 | 11.04:1 | 3.0 |
| hintText vs background | 6.15:1 | 11.56:1 | 4.5 |
| accent vs background | 4.58:1 | 8.61:1 | 3.0 |
| hintText vs backgroundSecondary | 5.3:1 | 10.2:1 | 4.5 |
| dieFace vs background (informational) | 1.14:1 | 1.26:1 | — |

### Pips

Plump circles, diameter = 0.165 of the die-card's shorter side (slightly oversized vs. a real d6's ~1/6, for a friendly dessert-scoop feel). Classic 3x3 grid arrangement: pip centers at offsets of -0.26, 0, +0.26 of the card's shorter side from center, so faces 1-6 use the traditional layouts. Each pip is a filled Circle() in the pips color with a barely-there dimensionality cue: a radial-gradient overlay from clear at center to pips-color-at-12%-opacity at the rim in light mode (an inner-shadow feel pressed into the cream), and in dark mode a 1.5pt-blurred glow of the pip color at 20% opacity behind each pip (embers). The cue is decorative only — the solid fill alone carries the 8.3:1 / 11.0:1 contrast. Pips appear/disappear via scale 0.6→1.0 spring per pip when the face changes.

### Animation

Springy and buoyant, like a scoop of sorbet dropped onto a plate. Roll: (1) on tap, the card squashes to scaleX 1.03 / scaleY 0.94 over 0.08s easeOut (anticipation); (2) tumble phase ~0.55s: faces flicker every ~70-90ms while the card wobbles rotationEffect between -4° and +4° keyed off the displayed face, driven by .spring(duration: 0.25, bounce: 0.55), and floats up to scale 1.02; (3) settle: final face lands with .spring(response: 0.45, dampingFraction: 0.55) back to scale 1.0 and 0° — one visible overshoot bounce, no more. Pips on the final face pop in staggered by 15ms each with .spring(response: 0.3, bounce: 0.4). Hint text fades with easeOut 0.4s. Reduce Motion: all rotation, scale, squash, and stagger are disabled; face changes become a plain 0.2s opacity crossfade of the pip layer, the tumble flicker is shortened to 2 face swaps, and the settle haptic still fires so the roll retains a physical endpoint. Increase Contrast variant: light mode deepens pips/hintText/accent to #6B2814 / #6E3118 / #96361C and strengthens dieBorder to #D89C74 at 2.5pt; dark mode brightens pips/hintText to #FFEBDB / #FFDFC4, lifts dieBorder to #8A5C42, and flattens the background gradient to solid background color so text never sits on the lighter stop.

### Haptics

Warm, rounded, two-beat landing — nothing sharp. SwiftUI-only implementation: during the tumble, .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.35), trigger: displayedFace) gives a muffled tick per face flicker; on settle, a soft double-tap via two triggers — .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.8), trigger: rollCount) at landing, then a state var bumped by Task.sleep(90ms) firing .impact(flexibility: .soft, intensity: 0.5) — a "duh-dum" heartbeat, the die touching down then rocking to rest. CoreHaptics version (preferred when available): tumble = 4-6 transient events spaced 80-110ms with slight jitter, intensity 0.3-0.4 decaying, sharpness 0.15; settle = transient at t=0 intensity 0.85 sharpness 0.25, transient at t=0.09s intensity 0.5 sharpness 0.15, plus a continuous event t=0-0.12s intensity 0.2 sharpness 0.05 underneath the pair to round the attack into one warm thump-thump. All sharpness values stay <= 0.25 to keep the feel pillowy rather than clicky.

### Design notes

All hard gates verified with WCAG 2.x relative luminance. Light: pips #83321B on dieFace #FFFBF2 = 8.34:1 (gate 3.0, aim 4.5 — exceeded); hintText #8A4226 = 6.15:1 on background #FFE8D6 and 5.30:1 on backgroundSecondary #FFD3BC (gate 4.5 against both gradient stops, so the hint may sit anywhere on the gradient); accent #B4472A = 4.58:1 / 3.95:1 vs both stops (gate 3.0). Dark: pips #FFDFC2 on dieFace #3E2620 = 11.04:1; hintText #F5C9A8 = 11.56:1 / 10.20:1 vs both stops; accent #FF9C78 = 8.61:1 / 7.59:1. Die face vs background is deliberately subtle (1.14:1 light, 1.26:1 dark — both under the ~1.3:1 threshold), so both palettes specify a dieBorder (#F3C4A6 light, #65402F dark) drawn as a 2pt continuous-curvature stroke; pairing it with a soft drop shadow (accent at 18% opacity, y-offset 10, blur 30 in light; black 40% in dark) keeps the card legible without breaking the hazy-sunset wash. Color-blind safety comes from lightness, not hue: every functional pair is a large luminance step (dark espresso-terracotta marks on near-white cream, and the inverse after dark), so the design survives full desaturation; the peach/coral hues are atmosphere only. The dark palette is a true companion, not an inversion — the same pigment family shifted to embers: backgrounds are deep toasted browns with a red-orange undertone, the die face is cocoa rather than glaring cream (kind to dark-mode eyes at night), and the pastels reappear as the luminous elements. cornerRadius 48pt with .continuous style on a ~357pt-wide card (iPhone width minus 18pt margins) matches physical dice proportions (~13% of face width) and reads as an iOS squircle. Springy animation and soft double-tap haptics both express the same brand adjective — buoyant softness — and both degrade gracefully: Reduce Motion keeps only a crossfade plus the settle haptic, and the Increase Contrast variant strengthens exactly the three roles users read (pips, hint, accent) plus the border, without changing the design's identity.


---

## 3. Matcha Garden

A near-full-screen paper-cream die resting on a pale sage field, like a smooth stone on moss. The die is a full-bleed continuous-corner card inset 16pt from the safe area on all sides (hint text overlaid in the bottom margin band, vertically centered in the inset). Everything is matte and organic: no gloss, no hard shadows — the die lifts off the background with a 1pt muted-sage hairline border plus a very soft ambient shadow (black 6% opacity, radius 24, y-offset 8 in light; omitted in dark, where the border does the separation). backgroundSecondary is a subtle radial wash behind the die (center bottom) that gives the field gentle depth without gradient banding. The accent green appears only in micro-moments: the roll-count/last-result caption if added later, focus rings, and the brief settle glow on the die border (border animates accent for 300ms on settle, then fades back). Under Increase Contrast (colorSchemeContrast == .increased): light mode deepens pips to #263B2A, hintText to #2C3E31, border to #6B8265 at 2pt; dark mode brightens pips to #F5F1E1, hintText to #C6D8C3, border to #718C78 at 2pt — every gated ratio rises, nothing shifts hue.

### Palette

| Role | Light | Dark |
|------|-------|------|
| Background | `#DEE9D8` | `#131B15` |
| Background (secondary) | `#CFDFC7` | `#1B2620` |
| Die face | `#FBF7EC` | `#24312A` |
| Die border | `#9FB694` | `#4A5F50` |
| Pips | `#38513C` | `#E9E4D0` |
| Hint text | `#3F5244` | `#A7BCA4` |
| Accent | `#4C7454` | `#86B98F` |

### Verified contrast (WCAG 2.x)

| Pair | Light | Dark | Gate |
|------|-------|------|------|
| pips vs dieFace | 8.14:1 | 10.64:1 | 3.0 |
| hintText vs background | 6.7:1 | 8.68:1 | 4.5 |
| accent vs background | 4.26:1 | 7.82:1 | 3.0 |
| hintText vs backgroundSecondary | 6.01:1 | 7.71:1 | 4.5 |
| dieFace vs background (informational) | 1.17:1 | 1.29:1 | — |

### Pips

Perfect matte circles drawn as SwiftUI Circle() fills — no stroke, no gradient. Pip diameter = 0.16 x die-card width (about 57pt on a 393pt-wide card, reads clearly from arm's length). Layout on the classic d6 quincunx grid: pip centers inset 0.26 x width from each edge, center pip dead center — calm and symmetrical, nothing playful or scattered. The only organic touch: on settle, pips grow in from 0.85 scale with a 0.35s spring (bounce 0.1), staggered 30ms per pip in reading order, like dew forming. GeometryReader supplies the width; a static [face: [CGPoint]] table (unit coordinates) supplies positions, so the whole face is one canvas-cheap ZStack.

### Animation

Settles like a leaf. Roll lasts ~0.9s total. Phase 1, sway (0-0.65s): the die card rocks around its center with a decaying keyframe rotation +4 deg, -3, +2, -1, 0 (easeInOut segments of ~0.13s each) while drifting down 8pt and back — no scale-up, no spin; it should feel like air moving, not force. Face values flicker on a decelerating schedule (every 80ms, then 120, then 180) via the pip table swap, each swap a 90ms opacity crossfade. Phase 2, settle (0.65-0.9s): final face lands with spring(duration: 0.6, bounce: 0.12) on rotation/offset — fully damped, max 1 deg overshoot — pips run their staggered dew-drop scale-in, and the border flashes accent for 300ms (easeOut fade). Reduce Motion: no rotation, no drift, no pip stagger; face changes become plain 0.2s opacity crossfades, the border still does its accent fade (opacity-only, allowed), and the existing VoiceOver announcement carries the result.

### Haptics

One muted, earthy thud at settle — nothing during the sway (silence while the leaf falls is the point). SwiftUI-only version: .sensoryFeedback(.impact(weight: .heavy, intensity: 0.55), trigger: viewModel.rollCount) — heavy weight at low intensity produces a dull, round knock rather than a click; fire it when the settle phase begins (trigger already increments at settle in the current view model). CoreHaptics version for the full earthy character: a single CHHapticEvent .hapticTransient at t=0 with intensity 0.55, sharpness 0.15 (low sharpness = soft felt-mallet body), immediately followed by a .hapticContinuous tail from t=0.005 to t=0.085 at intensity 0.22, sharpness 0.05 with an intensity envelope decaying linearly to 0 — the 80ms decay tail reads as the thud resonating into wood. No touch-down haptic on tap; keep the interaction one-gesture, one-thud. Respect system settings: CoreHaptics path checks CHHapticEngine.capabilitiesForHardware().supportsHaptics and falls back to the sensoryFeedback form.

### Design notes

All hard gates verified with WCAG 2.x relative luminance math. Light: pips #38513C on dieFace #FBF7EC = 8.14:1 (gate 3.0, aim 4.5 — cleared); hintText #3F5244 on background #DEE9D8 = 6.70:1 (gate 4.5); accent #4C7454 on background = 4.26:1 (gate 3.0); hintText also holds 6.01:1 over backgroundSecondary. Dark: pips #E9E4D0 on dieFace #24312A = 10.64:1; hintText #A7BCA4 on background #131B15 = 8.68:1; accent #86B98F on background = 7.82:1. Die face vs background is 1.17:1 (light) and 1.29:1 (dark), both under the 1.3 threshold, so both palettes carry a dieBorder (#9FB694 at 1.75:1 vs light bg; #4A5F50 at 2.55:1 vs dark bg) — the card edge never disappears. Color-blind safety comes from lightness, not hue: every meaningful pairing spans a large luminance gap (dark-forest pips on cream, mid-green accent against very pale or very dark fields), so the design survives full desaturation; green is atmosphere, never the sole information channel. The dark palette is a true companion, not an inversion: deep eucalyptus night background with a dark matcha-slate die and muted-cream pips keeps the paper-and-plant relationship (light marks on a warm surface) while staying dim enough for OLED. cornerRadius 48pt with .continuous curvature sits concentric with modern iPhone display corners at a 16pt margin and gives the near-full-screen card a soft river-stone silhouette. The animation and haptic follow one physical metaphor — a leaf drifting down and touching earth — so motion, sound of the thud, and the dew-drop pip entrance all agree; Reduce Motion collapses cleanly to crossfades because every effect is either rotation/offset (dropped) or opacity (kept).


---

## 4. Lavender Haze

A dreamy dusk-sky d6: the screen is a wash of pale lavender mist and the die is a full-bleed lilac card floating just above it, like a shape seen through evening haze. Everything is one violet family — lilac, periwinkle, dusty plum — separated by lightness, never by hue. Light mode is dawn-lavender; dark mode is the same sky an hour after sunset: deep blue-violet ground with the die as a slightly lifted slab of dusk and pale-lavender pips glowing like early stars. The mood is quiet and floaty; nothing snaps, everything drifts and settles.

### Palette

| Role | Light | Dark |
|------|-------|------|
| Background | `#EFEBF8` | `#171223` |
| Background (secondary) | `#E3DCF3` | `#211A32` |
| Die face | `#DFD6F2` | `#2E2647` |
| Die border | `#B7A8DC` | `#544787` |
| Pips | `#463A66` | `#DCD3F4` |
| Hint text | `#544878` | `#B3A7D8` |
| Accent | `#6A58A8` | `#A695E3` |

### Verified contrast (WCAG 2.x)

| Pair | Light | Dark | Gate |
|------|-------|------|------|
| pips vs dieFace | 7.31:1 | 9.88:1 | 3.0 |
| hintText vs background | 6.95:1 | 8.22:1 | 4.5 |
| accent vs background | 5.01:1 | 7:1 | 3.0 |
| hintText vs backgroundSecondary | 6.13:1 | 7.5:1 | 4.5 |
| dieFace vs background (informational) | 1.19:1 | 1.29:1 | — |

### Pips

Circles drawn as custom SwiftUI Circle() shapes in GeometryReader — no SF Symbols. Pip diameter = 0.16 x die-card width (about 57pt on a ~358pt card: iPhone width minus 16pt margins). Positions on the classic 3x3 anchor grid at 27% / 50% / 73% of the card's width and height, so the constellation breathes with generous negative space rather than crowding the corners. Personality: soft-edged, not clinical — each pip is a solid `pips`-colored circle with a 1.5pt-blurred shadow of the same color at 18% opacity offset (0, 2), giving a faint halo like a star through haze (the crisp solid core carries all the contrast; the halo is decoration only). On settle, pips fade+scale in from 0.85 scale / 0 opacity with a 30ms stagger ordered center-outward, so the new face 'condenses' rather than pops. The die card itself: fill `dieFace`, continuous-curvature 44pt corners, 1.5pt `dieBorder` stroke inset, plus a very soft ambient shadow (accent color at 12% opacity, radius 24, y 8) to lift it off the near-identical background.

### Animation

Floaty tumble with a soft overshoot settle, ~1.1s total. Phase 1 — drift (0 to 0.75s): faces flicker at a decelerating cadence (intervals 80, 90, 105, 125, 150, 185ms; consecutive faces always differ), while the whole card slow-wobbles between -4 and +4 degrees keyed off the displayed face and scales up to 1.03, each step animated with .easeInOut(duration: 0.12) so the wobble feels like floating, not shaking. Face swaps crossfade via .contentTransition(.opacity) over 120ms — hazy, not strobing. Phase 2 — settle (0.75 to ~1.1s): rotation and scale return to identity with spring(response: 0.7, dampingFraction: 0.68) — one visible soft overshoot (~1.5 degrees / 1.008 scale past rest) then rest, no secondary bounce; simultaneously the final face's pips do their center-out 30ms-stagger condense. Reduce Motion ON: no wobble, no scale, no overshoot, no pip stagger; the roll becomes two gentle opacity crossfades — old face fades to 40% and back with the new value over 0.35s total — and the result announcement is unchanged. Increase Contrast ON: dieBorder swaps to a stronger value (light #8A77BF, dark #7A6BB0) at 2.5pt, pip halo shadows are removed (crisp edges only), hintText and pips swap to deeper/paler variants (light: pips #2E2450, hint #3D3260, accent #4F3E8E; dark: pips #F0EAFB, hint #D6CCF0, accent #C4B7F2), and the ambient card shadow is dropped in favor of the border doing the separation work.

### Haptics

Feather-light tick sequence that exhales to nothing, then one soft landing. Preferred CoreHaptics pattern (CHHapticEngine, all transient events): ticks at t = 0.00, 0.08, 0.17, 0.275, 0.40, 0.55, 0.735s — mirroring the visual flicker cadence — with intensity fading 0.50, 0.42, 0.34, 0.27, 0.20, 0.15, 0.10 and sharpness fading 0.35, 0.32, 0.28, 0.25, 0.22, 0.18, 0.15 (progressively duller as well as quieter, so the tail dissolves rather than stops). Settle event at t = 1.05s, aligned with the spring's overshoot peak: one transient, intensity 0.55, sharpness 0.20 — a pillow thud, deliberately softer than the old .impact(weight: .medium). Pure-SwiftUI fallback (no CoreHaptics): drive a @State tickIndex from the flicker loop and attach .sensoryFeedback(trigger: tickIndex) returning .impact(weight: .light, intensity: max(0.1, 0.5 - Double(tickIndex) * 0.07)), plus .sensoryFeedback(.impact(weight: .light, intensity: 0.55), trigger: rollCount) on settle. Haptics play in full under Reduce Motion (they replace the missing visual tumble as the roll's texture); respect the system if the user disables haptics globally — sensoryFeedback and CHHapticEngine both no-op appropriately.

### Design notes

Every hard gate was verified with the WCAG 2.x relative-luminance formula. Light mode: pips #463A66 on dieFace #DFD6F2 = 7.31:1 (gate 3.0, aim 4.5 — exceeded); hintText #544878 on background #EFEBF8 = 6.95:1 (gate 4.5); accent #6A58A8 on background = 5.01:1 (gate 3.0); hint also holds 6.13:1 on backgroundSecondary if overlaid there. Dark mode: pips #DCD3F4 on dieFace #2E2647 = 9.88:1; hintText #B3A7D8 on background #171223 = 8.22:1; accent #A695E3 on background = 7.00:1. Die face vs background is intentionally hazy (1.19:1 light, 1.29:1 dark — both under the 1.3 threshold), so dieBorder is specified in both palettes: #B7A8DC (1.56:1 vs face) and #544787 (1.77:1 vs face), with the accent-tinted shadow adding non-color separation; Increase Contrast promotes the border to 2.5pt in stronger values. Color-blind safety: the entire palette is one violet hue, so no information is carried by hue at all — every functional pair is separated by large lightness gaps (pips are ~7-10x the luminance distance of decoration), which survives all dichromacies and grayscale. The dark palette is a true dusk companion, not an inversion: deep desaturated blue-violets (#171223/#2E2647) keep the pastel identity at low luminance while pale lavender takes over the foreground role. cornerRadius 44 with .continuous curvature sits concentric inside iPhone display corners given the ~16pt card margins. The floaty 1.1s tumble, decaying feather ticks, and soft 0.55-intensity landing all express the same idea: a die falling through haze.


---

## 5. Candy Pop

A gumball-machine toy: one huge squishy candy tile filling the screen edge-to-edge on a neutral cream base. The die card is a full-bleed continuous-corner rounded rectangle inset 20pt horizontally and vertically centered (roughly 353pt wide, ~72% of screen height on an iPhone 15), with the hint text sitting below it on the cream background. The card re-tints to the NEXT candy shade on every roll, cycling mint -> sky -> butter -> pink (light: #B8ECD7, #BFE0F7, #FBE7AE, #F9CBDD; dark companions: #2A4A40, #26405A, #4A3D20, #4E2742), so each roll feels like a new gumball dropping. The tint is purely decorative — the face value is always conveyed by pip count, and one deep plum pip color (#45254A light / warm cream #FFF3E2 dark) passes 9.0:1+ on every tint in both modes, so the cycling can never break a contrast gate. The structured dieFace/dieBorder values are the mint (face 1 / app-launch) state; the other three verified tints above are the rotation. Dark mode is a candy shop after closing: deep plum-cocoa background #211A24 with the same four sweets in muted jewel-toned deep versions, lit by cream pips.

### Palette

| Role | Light | Dark |
|------|-------|------|
| Background | `#FAF3E7` | `#211A24` |
| Background (secondary) | `#F3E6CF` | `#2B2230` |
| Die face | `#B8ECD7` | `#2A4A40` |
| Die border | `#2E7D64` | `#7FC8AC` |
| Pips | `#45254A` | `#FFF3E2` |
| Hint text | `#5F4C3C` | `#DCCFC2` |
| Accent | `#C24478` | `#F291BE` |

### Verified contrast (WCAG 2.x)

| Pair | Light | Dark | Gate |
|------|-------|------|------|
| pips vs dieFace | 9.91:1 | 8.91:1 | 3.0 |
| hintText vs background | 7.36:1 | 11.11:1 | 4.5 |
| accent vs background | 4.33:1 | 7.73:1 | 3.0 |
| hintText vs backgroundSecondary | 6.59:1 | 10:1 | 4.5 |
| dieFace vs background (informational) | 1.19:1 | 1.74:1 | — |

### Pips

Chunky gumdrop circles: plain SwiftUI Circle()s with diameter = 0.155 x card width (~55pt on a 353pt card — far fatter than a real die's ~0.12, deliberately toy-like), laid out on the classic 3x3 anchor grid inscribed in a centered square 0.62 x card width. Standard d6 arrangements (corners/center), no rotation of the grid. Each pip carries a subtle candy gloss: a second Circle at 22% of pip diameter, white at 35% opacity (light mode) / 20% (dark), offset up-left by 18% of pip radius — decorative only, contrast is carried entirely by the #45254A / #FFF3E2 fill (9.0-11.3:1 on every face tint). On settle, pips pop in with a 25ms stagger (see animation). Die border: 2pt stroke inset just inside the card edge using dieBorder — required in light mode where face-vs-background is 1.19:1 (border itself is 4.5:1 vs background, 3.8:1 vs face); kept in dark mode for consistency (5.0:1 vs face).

### Animation

Bounciest of the set — full squash-and-stretch cartoon physics. (1) Anticipation: on tap the card squishes to scaleEffect(x: 1.03, y: 0.93) with a -3 degree tilt, easeIn 80ms — a gumball machine crank-down. (2) Tumble ~500ms: faces flicker every ~70ms (existing viewModel cadence) while the card wobbles between +6/-6 degrees keyed off displayedFace, each swing animated with .spring(duration: 0.22, bounce: 0.55), and scale sits at 1.04. Simultaneously the card's tint crossfades to the next candy shade over 0.3s easeOut. (3) Settle: card overshoots to 1.06 then lands at 1.0 via .spring(response: 0.35, dampingFraction: 0.55) — a visible jelly wobble — while the final face's pips pop in staggered 25ms apart, each scaling 0.3 -> 1.0 with .spring(duration: 0.3, bounce: 0.6). Reduce Motion: zero scale, rotation, or squash; face changes become 0.2s opacity crossfades, the tint change stays as a plain crossfade (it is a color fade, not motion), pips appear at full size with a simple fade, and total roll duration shortens to ~350ms. Increase Contrast variant: light mode deepens pips to #2B1430, hintText to #4A3B30, accent to #A83364, and thickens the border to 3pt at #245F4C; dark mode raises pips to #FFFFFF, hintText to #F2EAE0, border to #9ADFC4, accent to #F7ABCC; the gloss highlight on pips is dropped.

### Haptics

Playful light-light-medium triplet, like a gumball rattling twice then landing. SwiftUI-only implementation: three sensoryFeedback modifiers on distinct triggers — .impact(weight: .light, intensity: 0.55) fired on rollCount (tap moment), .impact(weight: .light, intensity: 0.55) fired ~120ms later on a mid-tumble state flip, and .impact(weight: .medium, intensity: 1.0) fired on the settle trigger (~550ms), replacing the current single settle impact. Preferred CoreHaptics pattern (one CHHapticPattern played at tap): transient at t=0.00 intensity 0.45 sharpness 0.72; transient at t=0.12 intensity 0.45 sharpness 0.72; then optional tumble texture — micro-transients every 70ms from t=0.20 to t=0.48 at intensity 0.18 sharpness 0.90, one per face flicker; finale transient at t=0.55 intensity 1.00 sharpness 0.35 (low sharpness = soft rubbery thud, matching the jelly settle). Haptics play unchanged under Reduce Motion (retimed to the shortened 350ms roll: second light at t=0.10, thud at t=0.32) — they become the primary roll feedback when animation is suppressed.

### Design notes

All gates verified with WCAG 2.x relative luminance math. LIGHT: pips #45254A vs face tints = 9.91 (mint #B8ECD7), 9.42 (sky #BFE0F7), 10.60 (butter #FBE7AE), 9.04 (pink #F9CBDD) — every rotation state clears the 4.5 aim, not just the 3.0 gate; hintText #5F4C3C vs background #FAF3E7 = 7.36 (>= 4.5, also 6.59 vs backgroundSecondary); accent #C24478 vs background = 4.33 (>= 3.0, and 3.65 vs the mint face so it can sit on the card); dieFace vs background = 1.19 (< 1.3), so dieBorder #2E7D64 is specified — 4.50 vs background, 3.78 vs face. DARK: pips #FFF3E2 vs deep tints = 8.91 (mint #2A4A40), 9.76 (slate #26405A), 9.68 (gold-cocoa #4A3D20), 11.32 (berry #4E2742); hintText #DCCFC2 vs background #211A24 = 11.11; accent #F291BE vs background = 7.73; dieFace vs background = 1.74 (above 1.3, border kept anyway at 8.69 vs background). Color-blind safety: value is encoded only in pip count, and every functional pair (pips/face, hint/background, accent/background) is separated by a large lightness gap — the four candy hues sit in one narrow lightness band and carry zero information, so the design reads identically under any dichromacy. The dark palette is a true companion, not an inversion: the same four sweets desaturated and pushed deep (mint stays green, pink stays berry) on a plum-cocoa ground, with the cream from the light background migrating into the pips and hint text. cornerRadius 56pt continuous (.rect(cornerRadius: 56, style: .continuous)) on the ~353pt card gives the squishy vinyl-toy silhouette without crowding corner pips (grid square is 219pt, leaving 67pt corner margins).

---

## Implementation sketch (shared)

- A `DiceTheme` struct (palette + metrics + haptic pattern + animation
  parameters) with one static instance per style; the chosen style becomes
  the default, others remain available behind a debug picker if wanted.
- `DieFaceView` is replaced by a custom full-bleed card:
  `RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)`
  with pips as `Circle()`s on the classic 3x3 grid (offsets ±0.26 of the
  card's shorter side; diameters 0.16–0.17 per style).
- Colors defined in the asset catalog with light/dark variants so the
  system switches modes automatically; Increase Contrast variants via
  `UIAccessibility.isDarkerSystemColorsEnabled` or high-contrast asset
  variants.
- Haptics move from a single `sensoryFeedback(.impact)` to a per-theme
  pattern; CoreHaptics (`CHHapticEngine`) where a style needs sharpness
  control, with capability check and `sensoryFeedback` fallback.
