# Dice App — Development Plan

## 1. Goal (v1)

A native iOS app that shows a single six-sided die. Tapping anywhere on the
screen rolls it: a brief tumble animation plays, then the die settles on a
uniformly random face (1–6). One screen, no menus, no settings — it should
feel instant and satisfying.

## 2. Stack & requirements

- **Swift + SwiftUI**, no third-party runtime dependencies.
- **Minimum iOS 17** — allows `@Observable`, `sensoryFeedback`, and modern
  animation APIs. (Drop to iOS 16 only if older-device support is needed.)
- **Xcode 16 on macOS** to build and run. Note: this remote (Linux) session
  can author all source and project configuration, but cannot compile or run
  iOS apps — build verification happens in Xcode/Simulator on a Mac.
- Portrait-first but works in both orientations; supports light and dark mode.

## 3. Randomness & entropy

Requirement: every roll is independent, uniform over {1…6}, and unpredictable.

- **Source:** rolls call `Int.random(in: 1...6, using:)` with Swift's
  `SystemRandomNumberGenerator`. On Apple platforms this is backed by the OS
  CSPRNG (`arc4random_buf`), which the kernel seeds and *continuously
  reseeds* from its entropy pool — fed by hardware sources including the
  SoC's true random number generator (the Secure Enclave TRNG on modern
  devices) and interrupt-timing jitter. Practical effect: each roll consumes
  fresh hardware-derived entropy, and there is no app-managed seed to guess,
  leak, or accidentally reuse.
- **Bias-free mapping:** 2⁶⁴ is not divisible by 6, so mapping raw random
  words with `% 6` would slightly overweight some faces. Swift's
  `Int.random(in:)` performs unbiased range reduction (Lemire
  multiply-with-rejection), so every face gets exactly 1/6 probability.
  Rule for this codebase: never map random values with `%`.
- **Deliberately avoided:**
  - Seeding our own generator (GameplayKit sources, `srand48` with a time
    seed, etc.) — predictable and strictly worse than the system CSPRNG.
  - "Entropy theater" such as mixing in tap coordinates, timestamps, or
    accelerometer noise. The kernel already harvests hardware entropy at far
    higher rate and quality; app-level mixing adds complexity, not
    randomness.
- `SecRandomCopyBytes` draws from the same kernel CSPRNG and would be an
  equivalent (not better) alternative; `SystemRandomNumberGenerator` is the
  idiomatic choice.
- **Repeats are legitimate:** a real die lands on the same face ~1/6 of the
  time. We do not force the next face to differ — that would skew the
  per-roll distribution and correlate consecutive rolls. The roll animation
  (§5) makes a repeated face still read as a fresh roll.
- **Verified by tests** (§7): bounds, deterministic sequences via an injected
  seeded generator, and a chi-squared uniformity sanity check.

## 4. Architecture

Small and testable — the point is isolating the roll logic, not ceremony.

- **`Die`** (model, value type): `sides: Int` (6 for v1) and
  `roll(using: inout some RandomNumberGenerator) -> Int`. Generic over the
  RNG so production uses the system generator and tests inject a
  deterministic one.
- **`DiceRollViewModel`** (`@Observable`): current face, `isRolling` flag,
  and the roll choreography (start flicker, settle on the final value).
  Re-entrancy guard: taps during the ~0.6 s roll are ignored (restarting
  mid-roll feels jarring; queueing adds nothing).
- **Views:**
  - `DiceRollScreen` — full-screen layout; `contentShape(Rectangle())` +
    `onTapGesture` so the *entire* screen (including empty space) is the
    tap target.
  - `DieFaceView` — renders a single face 1–6.
- **`DiceApp`** — app entry point.

## 5. UI & interaction

- **Die rendering (v1):** SF Symbols `die.face.1` … `die.face.6` — crisp at
  any size, free, adapts to dark mode. (v2 option: custom `Canvas`-drawn
  face with a pip grid, for theming.)
- **Roll feel** (~0.5–0.7 s total): the face flickers through random values
  every ~60–80 ms while the die does a springy scale/rotation wobble, then
  settles on the final value with a small overshoot spring. Implemented with
  a short `Task`-based timer loop plus `withAnimation(.spring)`.
- **Haptics:** `sensoryFeedback(.impact)` when the die settles.
- **Accessibility:** the die is one accessibility element ("Die, showing
  four"); each roll posts an announcement with the result; the screen acts
  as a "Roll" button; Reduce Motion replaces the wobble with a crossfade.
- **Visual:** die centered on a soft background with a "Tap anywhere to
  roll" hint that fades out after the first roll.

## 6. Project setup & structure

Because this environment can't run Xcode, the project must be reproducible
from text:

- **Recommended: XcodeGen.** Commit a `project.yml` plus sources; running
  `xcodegen generate` (`brew install xcodegen`) produces the `.xcodeproj`.
  Keeps noisy pbxproj churn out of code review.
- **Alternative (zero extra tooling):** create the app once in Xcode on the
  Mac and commit the `.xcodeproj`; after that, only source files change.

```
dice-app/
├── project.yml
├── PLAN.md
├── DiceApp/
│   ├── DiceApp.swift
│   ├── Models/Die.swift
│   ├── ViewModels/DiceRollViewModel.swift
│   ├── Views/DiceRollScreen.swift
│   ├── Views/DieFaceView.swift
│   └── Assets.xcassets
└── DiceAppTests/
    ├── DieTests.swift
    └── SeededGenerator.swift
```

## 7. Testing

- **Unit (fast, deterministic):**
  - `Die` results always within 1…6.
  - Injected seeded generator yields the expected sequence (proves the RNG
    is actually pluggable and the mapping is stable).
  - Chi-squared uniformity sanity check over ~60 k system-RNG rolls with a
    loose threshold — catches gross regressions without flaky CI.
  - View model settles with `isRolling == false` and the displayed face
    matching the final roll; taps mid-roll are ignored.
- **UI test:** launch, tap the screen, assert the roll happened via a roll
  counter / accessibility value (the face itself may legitimately repeat, so
  never assert "face changed").
- **Manual on-device:** haptics, animation feel, Reduce Motion path.

## 8. Milestones

Each milestone is a runnable app and a clean commit:

1. **M1 — Scaffold:** `project.yml`, app entry, empty screen renders in the
   simulator.
2. **M2 — Static die:** `Die` model + `DieFaceView` showing a fixed face;
   unit tests for `Die`.
3. **M3 — Tap to roll:** full-screen tap → instant random face;
   re-entrancy guard; view-model tests.
4. **M4 — Roll feel:** flicker + spring animation, haptics, Reduce Motion
   fallback.
5. **M5 — Polish:** app icon, hint text, accessibility pass, README with
   build steps.

## 9. Later (explicitly out of v1 scope)

Die-type picker (d4/d8/d10/d12/d20); multiple dice with totals;
shake-to-roll via CoreMotion; roll history; sound effects; 3D die
(SceneKit/RealityKit). The `Die.sides` abstraction and pluggable RNG are the
only v1 concessions to this future.
