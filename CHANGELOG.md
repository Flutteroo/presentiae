
## 1.9.19, v1 app completely refreshed to v2, 2025-09-18 04:30:39, 09e6304
- `lib/physics_config.dart`: Introduced adaptive physics parameters (added maxSpeed & bounceAngleVariation) enabling downstream normalization and controlled randomness; factory defaults tuned for energetic motion (friction 0.990, wallBounciness 3.2) plus non-deterministic bounce injection (±10°).
- `lib/ball.dart`: Added real-time telemetry pipeline (distance, speed, impact force, dynamic bounciness, rawPixelSpeed) with exponential smoothing (α=0.1) and adaptive max speed tracking; implemented stochastic post-collision vector perturbation honoring configurable bounceAngleVariation; migrated painter to speed-aware color mapping (shared thresholds with LED indicator) for coherent UX; added calibration reset hook.
- `lib/led_indicator.dart`: Abstracted generic, orientation-agnostic segmented display with threshold-driven color progression (0.4/0.7/0.9) and constant-time repaint logic; decoupled rendering via CustomPainter ensuring minimal layout overhead.
- `lib/main.dart`: Integrated adaptive LED gauge and synchronized speed color semantics; added dynamic scaling (_maxObservedSpeed) with gesture-based recalibration (long-press); refactored status cycle logic and consolidated metric presentation with monospace formatting for stable layout.
- `lib/digital_clock.dart`: Time zone–aware clock using timezone + intl stacks; lightweight blink state toggling per second without retaining unnecessary timers beyond lifecycle, ensuring low rebuild diff footprint.

## 2.0.1, v2 init, 2025-09-18 04:32:41, 6190080
README.md
TODO.md
presentiae-v1.gif
presentiae-v1.mov


