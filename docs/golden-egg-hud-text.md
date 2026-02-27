# Golden Egg HUD Text Behavior Specification

## Status
Documentation-only request. No gameplay code, UI code, or runtime behavior changes are part of this update.

## Context
The previous implementation attempt for golden egg HUD text behavior needs a clean follow-up implementation pass. This document defines the expected behavior for that future coding pass.

## Required Behavior
1. The golden egg counter text appears directly to the right of the HUD golden egg image.
2. The counter text remains hidden until the first golden egg is collected during a run.
3. The displayed numeric value does not update immediately on collision. It increments only after the golden egg HUD animation fully completes.
4. The displayed value remains synchronized with persistent `goldenEggs` currency.

## Placement Specification
- Anchor: HUD golden egg icon.
- Horizontal relation: counter text starts at the icon's right edge with consistent spacing.
- Vertical relation: text is baseline- or center-aligned with the icon so both read as one compact currency component.
- Layering: text and shadow remain above gameplay background and do not conflict with score/life HUD.

## Timing Specification
For each golden egg collection event, use this sequence:
1. Update golden egg currency in authoritative game state.
2. Play golden egg collection animation.
3. Wait for animation completion.
4. Update HUD counter text to the new value.

If multiple golden eggs are collected close together, updates must still follow post-animation completion ordering and avoid skipped increments.

## Manual Validation Checklist
- Start a run and collect no golden eggs: counter text never appears.
- Collect first golden egg: animation completes, then counter appears with correct value.
- Collect another golden egg: value increments only after the next animation completion.
- Verify placement remains to the right of icon across supported device sizes and orientations.

## Scope Guardrail
This document intentionally captures requirements only. Implementation is deferred to a future coding pass.
