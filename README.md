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

### Game Modes
- **Easy Mode**: Slower gameplay, fewer enemies
- **Normal Mode**: Standard difficulty 
- **Hard Mode**: Faster gameplay, more frequent enemy spawns

### Customization
- **Character costumes**: Full-body outfits like hotdog, unicorn, cow
- **Accessories**: Head/face items like glasses, mask, gangster hat
- **Shop system** using golden eggs as currency
- **Default "bob" character** included for all players

### Additional Features
- **Tutorial system** for new players (auto-enabled for first-time players)
- **High score tracking** with persistent storage
- **Pause/resume functionality**
- **Particle effects** and smooth animations
- **Parallax scrolling background**
- **Achievement system** (Crown section)

## 🛠️ Technical Details

### Architecture
- **Built with SpriteKit** for iOS
- **Manager Pattern**: Organized with separate managers for different responsibilities:
  - `GameLogic`: Core game flow and state management
  - `InputManager`: Touch handling and button interactions  
  - `PhysicsContactHandler`: Collision detection and physics events
  - `ScrollingManager`: Background scrolling and eagle movement
- **Physics-based gameplay** using SpriteKit's physics engine
- **Efficient graphics** with texture atlases for performance

### Key Classes
- `GameScene`: Main game scene and coordinator
- `Player`: Player character with costume system
- `Eagle`/`Fox`: Enemy classes with AI behavior
- `Egg`: Collectible items (regular and golden)
- `Menu`/`Shop`/`Settings`: UI scenes
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
3. **Watch the shadows**: The HUD shows enemy positions as shadows
4. **Time your jumps**: Eagles fly at middle height, foxes run on the ground
5. **Practice makes perfect**: The tutorial helps, but higher scores unlock features

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
- **Object pooling** for frequently created/destroyed objects
- **Efficient physics** with appropriate collision detection
- **Smooth 60fps** gameplay on supported devices

### Code Organization
- **Separation of concerns** with manager classes
- **Consistent naming** and file organization
- **Modular design** for easy maintenance and feature additions

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
- **Updated**: 2025 with manager refactor and improvements
- **Engine**: SpriteKit by Apple

---

**Ready to start your egg-collecting adventure?** 🥚✨