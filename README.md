# Dice

A deliberately minimal iOS dice app: one six-sided die, tap anywhere on the
screen to roll it. A short tumble animation plays, a haptic tick lands when
the die settles, and the result is drawn from the system CSPRNG with
bias-free range reduction (see [PLAN.md](PLAN.md) §3 for the entropy
details).

## Building without a Mac (CI)

The `.xcodeproj` is **not** committed — [XcodeGen](https://github.com/yonaskolb/XcodeGen)
generates it from `project.yml`. GitHub Actions does the full build:

- Every push runs `.github/workflows/ci.yml` on a GitHub-hosted macOS
  runner: it installs XcodeGen, generates the project, and runs
  `xcodebuild test` against an iPhone simulator.
- No Apple Developer account is needed for this; simulator builds are
  unsigned (`CODE_SIGNING_ALLOWED=NO`).
- The XCUITest suite launches the real app, rolls the die twice, and
  attaches screenshots; CI exports them into a `screenshots` artifact on
  every run, so each build leaves visual evidence of the app working.
- The built simulator app is uploaded as the `DiceApp-simulator` artifact —
  drag it onto a Simulator, or upload the inner zip to a browser-based
  device service (e.g. appetize.io) to interact with it from any machine.
- On failure, the `.xcresult` bundle is uploaded as a workflow artifact for
  diagnosis.

So the repository can be developed from any machine; the macOS runner is
the only place a compile ever happens.

## Building locally (optional)

If you do have a Mac with Xcode 16+:

```sh
brew install xcodegen
xcodegen generate
open DiceApp.xcodeproj
```

Then run the `DiceApp` scheme (⌘R) or the tests (⌘U).

## Project layout

```
project.yml                 XcodeGen spec (targets, scheme, Info.plist)
DiceApp/
  DiceApp.swift             App entry point
  Models/Die.swift          Fair n-sided die; injectable RNG
  Models/AnyRandomNumberGenerator.swift
  ViewModels/DiceRollViewModel.swift   Roll state + flicker choreography
  Views/DiceRollScreen.swift           Full-screen tap target, haptics, a11y
  Views/DieFaceView.swift              SF Symbol die faces
DiceAppTests/
  DieTests.swift            Range, determinism, chi-squared uniformity
  DiceRollViewModelTests.swift
  SeededGenerator.swift     SplitMix64, tests only
```
