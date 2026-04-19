# Repository Map

## Root

- `README.md` — project overview, gameplay features, architecture notes, and setup instructions.
- `REPO_MAP.md` — this file.
- `docs/` — supplementary design and behavior documentation.
- `Hatchlet.xcodeproj/` — Xcode project/workspace metadata.
- `Hatchlet/` — SpriteKit game source code, scenes, gameplay systems, and assets.

## `docs/`

- `golden-egg-hud-text.md` — behavior spec for golden egg HUD text timing and visibility.

## `Hatchlet/` (App Target)

### Core Scene + Managers

- `GameScene.swift` — main SpriteKit scene that wires managers/systems together.
- `GameLogic.swift` — game flow, spawning, scoring, streaks, and run state.
- `InputManager.swift` — touch handling and player/control input routing.
- `PhysicsContactHandler.swift` — physics collision/contact event handling.
- `ScrollingManager.swift` — scrolling/parallax orchestration.
- `Emitters.swift` — particle emitter helpers and integration.
- `TextureFrameSort.swift` — texture frame sorting utility for animation frame loading.

### Shared UI + Config

- `gameHUD.swift` — in-game HUD (score, lives, streak, shadows, golden eggs).
- `ShadowLabelNode.swift` — text wrapper for consistent drop-shadow labels.
- `Constants.swift` — global constants and persisted key names.

### Scene Modules (`Scenes/`)

- `PauseScreen.swift` — in-game pause overlay and controls.
- `EndScreen.swift` — game-over summary screen.
- `Tutorial.swift` — tutorial sequence and progression UI.

### Menu/Navigation (`Navigation/`)

- `Menu.swift` — main menu scene.
- `Shop.swift` — cosmetics purchasing scene.
- `Settings.swift` — game settings scene.
- `Crown.swift` — achievements/high-score style scene.
- `Item.swift` / `ItemNode.swift` — shop/catalog models + display nodes.
- `oldNode.swift` — legacy node helper used by navigation flows.

### Gameplay Entities (`Attributes/`)

- `Player.swift` — player character state and animation.
- `Egg.swift` — collectible egg entity (regular/golden).
- `Fox.swift` / `Eagle.swift` — enemy behavior types.
- `Ground.swift` / `Roof.swift` / `Landscape.swift` / `Background.swift` / `ParallaxBG.swift` — world geometry and background layers.
- `Life.swift` — life/health-related representation.

### Support Files (`Support Files/`)

- `AppDelegate.swift` — app lifecycle entry.
- `GameViewController.swift` — SpriteKit view/controller bootstrap.
- `PhysicsCategory.swift` — physics bitmask/category definitions.
- `Base.lproj/Main.storyboard` — app storyboard.
- `Base.lproj/LaunchScreen.storyboard` — launch screen storyboard.
- `Actions.sks` — SpriteKit action resource file.
- `Fonts/` — bundled custom font assets.

### Data + Assets

- `Info.plist` — target runtime metadata/configuration.
- `Assets.xcassets/` — texture atlases, image sets, app icons, and art resources.
- `Emitters/` — `.sks` particle emitter definitions.

## Notes on Structure

- This project is a SpriteKit-based iOS game organized by feature area (`Scenes`, `Navigation`, `Attributes`) plus cross-cutting managers and utilities at the target root.
- Large binary art content lives in `Assets.xcassets`; executable logic is concentrated in Swift files under `Hatchlet/`.
