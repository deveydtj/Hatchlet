# Hatchlet 🥚

An endless runner mobile game for iOS built with SpriteKit where players control a character collecting eggs while avoiding enemies.

## 🎮 Game Overview

Hatchlet is a fast-paced endless runner where you:
- **Collect eggs** to score points and golden eggs for currency
- **Avoid enemies** like eagles (flying) and foxes (ground-based)
- **Navigate** through an increasingly difficult scrolling world
- **Customize** your character with costumes and accessories
- **Survive** as long as possible with your 3 lives

## ✨ Features

### Core Gameplay
- **Physics-based movement** with touch controls for jumping and horizontal movement
- **Progressive difficulty** - game speed increases as you score more points
- **Multiple enemy types** with different behaviors and spawn patterns
- **Two egg types**: Regular eggs for points, golden eggs for premium currency
- **Lives system** with 3 lives per game
- **Intro fox sequence** - an animated fox runs across the screen carrying an egg at the start of each round, shaking it before dashing off to trigger gameplay
- **Egg catch streak system** - consecutive catches build a streak displayed via a color-coded popup label near the catch location; colors escalate with streak milestones and streaks of 100+ cycle through a rainbow animation
- **Ground trail particles** - grass particles appear beneath the player while moving along the ground

### Game Modes
- **Easy Mode**: Slower gameplay, fewer enemies, eggs spawn every 1.5 seconds
- **Normal Mode**: Standard difficulty, eggs spawn every 1.25 seconds
- **Hard Mode**: Faster gameplay, more frequent enemy spawns, eggs spawn every 0.95 seconds

### Customization
- **Character costumes** (full-body outfits):
  - Bob — default, free
  - Cow — 5 golden eggs
  - Unicorn — 25 golden eggs
  - Hotdog — 100 golden eggs
- **Accessories** (head/face items):
  - Gangster hat — free
  - Mask — 5 golden eggs
  - Glasses — 5 golden eggs
- **Shop system** using golden eggs as currency
- **Default "bob" character** included for all players

### HUD & Feedback
- **Score display** updated in real time
- **Lives indicator** showing remaining lives (up to 3)
- **Shadow indicators** on the ground showing the positions of the player and active enemies
- **Golden egg counter** — hidden at run start; appears beside the golden egg icon after the first golden egg animation completes, and updates only after each collection animation finishes traveling to the HUD icon
- **Streak popup labels** showing the current consecutive catch count with dynamic color and size scaling

### End Screen
- **Final score** display
- **Best streak** for the run (e.g., "Best Streak: 5 eggs")
- **Streak summary saying** based on best streak:
  - 0 catches — "Ready for another crack?"
  - 1 catch — "Off to a start"
  - 2–4 — "Finding your rhythm"
  - 5–7 — "Eggcellent run"
  - 8–11 — "Hot streak"
  - 12–15 — "Cracking records"
  - 16+ — "Legendary hatch"

### Additional Features
- **Tutorial system** for new players (auto-enabled for first-time players; disabled automatically after reaching a score of 10)
- **High score tracking** with persistent storage
- **Achievements screen** (Crown) — displays your all-time high score
- **Pause/resume functionality**
- **Particle effects** and smooth animations
- **Parallax scrolling background**

## 🛠️ Technical Details

### Architecture
- **Built with SpriteKit** for iOS
- **Manager Pattern**: Organized with separate managers for different responsibilities:
  - `GameLogic`: Core game flow, spawning, scoring, streak tracking, and state management
  - `InputManager`: Touch handling and button interactions  
  - `PhysicsContactHandler`: Collision detection and physics events
  - `ScrollingManager`: Background scrolling and eagle movement
- **Physics-based gameplay** using SpriteKit's physics engine
- **Efficient graphics** with texture atlases for performance
- **Object pooling** for eggs, foxes, and eagles to minimize per-frame allocations
- **Low power mode awareness** — menu button animation frame count is reduced automatically on low-power or low-memory devices

### Key Classes
- `GameScene`: Main game scene and coordinator
- `GameLogic`: Core game flow, egg streak tracking, and intro fox sequence
- `gameHUD`: In-game HUD with score, lives, shadow indicators, golden egg counter, and streak popup
- `Player`: Player character with costume system
- `Eagle`/`Fox`: Enemy classes with AI behavior
- `Egg`: Collectible items (regular and golden)
- `EndScreen`: Post-game screen showing score, best streak, and streak summary
- `Menu`/`Shop`/`Settings`/`Crown`: UI scenes
- `ShadowLabelNode`: Wrapper around `SKLabelNode` for consistent shadowed text rendering
- `Constants`: Game configuration and persistent data

### Data Persistence
- Uses `UserDefaults` for:
  - High scores
  - Golden egg currency
  - Owned items and costumes
  - Game difficulty settings
  - Tutorial completion status

## 🚀 Getting Started

### Prerequisites
- Xcode 12.0 or later
- iOS 13.0 or later target
- macOS for development

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/deveydtj/Hatchlet.git
   ```

2. Open the project in Xcode:
   ```bash
   cd Hatchlet
   open Hatchlet.xcodeproj
   ```

3. Select your target device or simulator

4. Build and run (⌘+R)

### Controls
- **Tap anywhere**: Make the character jump/flap
- **Drag horizontally**: Move character left and right while jumping
- **Pause button**: Pause the game during play
- **Menu buttons**: Navigate through shop, settings, and achievements

## 🎯 Gameplay Tips

1. **Master the physics**: The character has momentum, so plan your movements
2. **Collect golden eggs**: These are rare but valuable for buying cosmetics
3. **Watch the shadows**: The HUD shows enemy positions as shadows on the ground
4. **Time your jumps**: Eagles fly at middle height, foxes run on the ground
5. **Build your streak**: Catching eggs back-to-back boosts your best streak score and earns bragging rights on the end screen
6. **Use Easy mode to learn**: Eggs spawn less frequently and enemies are slower — great for building consistent catching habits

## 🎨 Assets

The game includes rich visual assets:
- **Custom sprites** for characters, enemies, and collectibles
- **Particle effects** for impacts, movement, and collection
- **Multiple texture atlases** for efficient rendering
- **Custom fonts** (Amatic SC) for UI text
- **Animated sprites** for character actions and enemy movement

## 🏗️ Architecture Notes

### Performance Optimizations
- **Texture atlases** reduce draw calls
- **Object pooling** for eggs, foxes, and eagles — frequently spawned objects are recycled instead of reallocated
- **Efficient physics** with appropriate collision detection
- **Smooth 60fps** gameplay on supported devices
- **Low power mode adaptation** — animation frame counts are automatically reduced on constrained devices

### Code Organization
- **Separation of concerns** with manager classes
- **Consistent naming** and file organization
- **Modular design** for easy maintenance and feature additions

## 📝 Feature Specifications

- [Golden Egg HUD Text Behavior (documentation-only)](docs/golden-egg-hud-text.md)

## 🐛 Known Issues

This project has been analyzed and several improvements have been made:
- Memory leak fixes in closure captures
- Improved null safety with optional unwrapping
- Better error handling for edge cases

## 📱 Supported Devices

- **iPhone**: iOS 13.0+, Portrait orientation
- **iPad**: iOS 13.0+, All orientations supported
- Optimized for various screen sizes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on device/simulator
5. Submit a pull request

## 📄 License

Copyright © 2020-2025 Jacob DeVeydt. All rights reserved.

## 🙏 Credits

- **Original concept**: "Lil Jumper" 
- **Developer**: Jacob DeVeydt
- **Updated**: 2025 with manager refactor, egg catch streak system, intro fox sequence, ground trail particles, golden egg HUD travel animation, and low power mode optimizations
- **Engine**: SpriteKit by Apple

---

**Ready to start your egg-collecting adventure?** 🥚✨
