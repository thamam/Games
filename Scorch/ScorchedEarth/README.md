# Scorched Earth - Godot Remake

A modern remake of the classic 1991 DOS artillery game **Scorched Earth** built with Godot 4.

![Scorched Earth](icon.svg)

## Overview

Scorched Earth is a turn-based artillery strategy game where players control tanks on destructible terrain. Use physics-based ballistics to eliminate your opponents with an arsenal of devastating weapons while managing limited resources.

## Features

### Core Gameplay
- ✅ **Fully Destructible Terrain** - Every shot reshapes the battlefield
- ✅ **Physics-Based Combat** - Realistic ballistic trajectories with wind and gravity
- ✅ **Turn-Based Strategy** - Plan your shots and manage resources carefully
- ✅ **2-10 Player Support** - Human players and AI opponents

### Weapons Arsenal (13+ Weapons)
1. **Baby Missile** - Small, cheap projectile
2. **Missile** - Standard projectile (default)
3. **Heavy Missile** - Large explosive
4. **Baby Nuke** - Medium nuclear weapon
5. **Nuke** - Massive destruction
6. **MIRV** - Splits into 5 warheads at apex
7. **Funky Bomb** - Chaotic bouncing cluster bomb
8. **Napalm** - Incendiary bouncing weapon
9. **Roller** - Rolls down slopes
10. **Leapfrog** - Multiple bounces before detonation
11. **Dirt Ball** - Adds terrain
12. **Dirt Slapper** - Large dirt deposit
13. **Dirt Charge** - Removes terrain

### Game Systems
- ✅ **Procedural Terrain Generation** - Unique battlefield every match
- ✅ **AI Opponents** - Three difficulty levels
- ✅ **Economy System** - Money management and interest earning
- ✅ **Damage System** - Health, shields, fall damage
- ✅ **Wind Mechanics** - Variable wind affects projectile flight
- ✅ **Tank Movement** - Fuel-based repositioning

## Controls

### Player Controls
| Action | Key | Description |
|--------|-----|-------------|
| Adjust Angle Up | **Left Arrow** | Increase cannon angle |
| Adjust Angle Down | **Right Arrow** | Decrease cannon angle |
| Increase Power | **Up Arrow** | Increase shot power |
| Decrease Power | **Down Arrow** | Decrease shot power |
| Fire Weapon | **SPACE** | Launch current weapon |
| Move Left | **A** | Move tank left (requires fuel) |
| Move Right | **D** | Move tank right (requires fuel) |
| Select Weapon 1-9 | **1-9** | Quick select weapon |
| Restart Game | **R** | Restart (game over screen) |
| Quit | **ESC** | Exit game |

### Gameplay Tips
1. **Account for Wind** - Check the wind indicator and adjust your aim
2. **Use Terrain** - Destroy ground under enemies or create cover
3. **Manage Money** - Balance offensive and defensive spending
4. **Shields Save Lives** - Invest in shields for protection
5. **Fall Damage** - Parachutes prevent damage from long falls
6. **MIRV Timing** - MIRV splits at the apex of its trajectory
7. **Bank Shots** - Use bouncing weapons (Funky Bomb, Napalm) for creative angles

## How to Run

### Prerequisites
- **Godot 4.2+** - Download from [godotengine.org](https://godotengine.org/)

### Option 1: Run in Godot Editor (Recommended)
1. Install Godot 4.2 or newer
2. Clone or download this repository
3. Open Godot and click "Import"
4. Navigate to the `ScorchedEarth` folder
5. Select `project.godot` and click "Import & Edit"
6. Press **F5** or click the "Play" button to run the game

### Option 2: Export and Run
1. Open the project in Godot
2. Go to **Project → Export**
3. Add your platform export template
4. Export the project
5. Run the exported executable

### Quick Start (Linux)
```bash
# Clone the repository
cd Scorch/ScorchedEarth

# Run with Godot (if installed)
godot --path . res://scenes/Main.tscn

# Or open in editor
godot -e project.godot
```

## Deploy to Web (Vercel)

Want to play the game in your browser or share it online? Deploy to Vercel for free!

### Quick Deploy (5 minutes)
See **[VERCEL_QUICKSTART.md](VERCEL_QUICKSTART.md)** for the fastest way to get your game online.

### Full Deployment Guide
For detailed instructions, configuration options, and troubleshooting:
- 📖 **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete deployment guide

### What You Get
- 🌐 **Live Web Game** - Play in any modern browser
- 🚀 **Fast Global CDN** - Served from Vercel's edge network
- 🔄 **Auto-Deploy** - Updates automatically when you push to Git
- 📱 **Share Anywhere** - Just send the URL!

**Example:** `https://scorched-earth.vercel.app`

## Game Modes

### Current Implementation
- **Classic Mode** - 2 players (1 human vs 1 AI)
- **AI Difficulty Levels**:
  - **Lobber** (0): Random shots, poor accuracy
  - **Poolshark** (1): Medium difficulty, bank shots
  - **Spoiler** (2): Expert AI, near-perfect aim

### Future Modes
- Tournament Mode (scoring system)
- Team Mode (cooperative play)
- Custom Games (adjustable parameters)
- Campaign Mode (progressive challenges)

## Technical Details

### Architecture
- **Engine**: Godot 4.2
- **Language**: GDScript
- **Physics**: Custom 2D ballistics simulation
- **Terrain**: Pixel-based destruction using Image manipulation

### File Structure
```
ScorchedEarth/
├── project.godot           # Project configuration
├── icon.svg                # Game icon
├── scenes/
│   └── Main.tscn          # Main game scene
├── scripts/
│   ├── GameManager.gd     # Game state and turn management
│   ├── Terrain.gd         # Procedural terrain and destruction
│   ├── Tank.gd            # Tank controller and physics
│   ├── Projectile.gd      # Projectile physics and weapons
│   ├── Weapon.gd          # Weapon definitions and database
│   └── Main.gd            # Main scene orchestration
├── assets/
│   ├── sprites/           # Graphics (future)
│   ├── sounds/            # Sound effects (future)
│   └── music/             # Background music (future)
└── resources/             # Game resources
```

### Core Systems

#### 1. Terrain Generation
- **Midpoint Displacement Algorithm** for procedural terrain
- **Smoothing** for natural-looking landscapes
- **Pixel-Perfect Collision** using Image data
- **Real-Time Destruction** with radius-based modification

#### 2. Physics System
- **Ballistic Trajectories** with gravity simulation
- **Wind Effects** affecting all projectiles
- **Bounce Mechanics** for special weapons
- **Fall Damage** calculation for tanks

#### 3. Weapon System
- **Modular Design** - Easy to add new weapons
- **Resource-Based** - Weapons defined as Godot Resources
- **Special Behaviors** - MIRV splitting, bouncing, guidance
- **Dirt Manipulation** - Add or remove terrain

#### 4. AI System
- **Difficulty Levels** - Adjustable accuracy and behavior
- **Target Selection** - Smart target picking
- **Ballistic Calculation** - Approximate trajectory solving
- **Randomization** - Difficulty-based accuracy variance

## Development

### Completed Features ✅
- [x] Project setup and configuration
- [x] Procedural terrain generation
- [x] Terrain destruction physics
- [x] Tank controller with movement
- [x] Projectile physics system
- [x] 13+ weapon implementations
- [x] Turn management system
- [x] AI opponents (3 difficulty levels)
- [x] Basic UI and HUD
- [x] Wind mechanics
- [x] Damage and health system
- [x] Game over and restart

### Planned Features 📋
- [ ] Shop/purchasing UI
- [ ] Defensive items (shields, parachutes, batteries)
- [ ] Enhanced visual effects (particles, animations)
- [ ] Sound effects and music
- [ ] Main menu and settings
- [ ] Multiple game modes
- [ ] Multiplayer (local hotseat)
- [ ] Online multiplayer
- [ ] Statistics and leaderboards
- [ ] Save/load game state
- [ ] Custom terrain themes
- [ ] More weapons (guided missiles, heat-seeking)

### Contributing
This is a remake/learning project. Feel free to:
- Report bugs or issues
- Suggest new weapons or features
- Submit pull requests
- Create your own forks and variations

## Credits

### Original Game
- **Scorched Earth** (1991) by Wendell Hicken
- Published by Wendell Hicken

### This Remake
- **Engine**: Godot Engine 4.2
- **Development**: 2025
- **License**: Educational/Fan Project

### Inspiration
Based on the classic DOS game that popularized the artillery game genre, inspiring titles like:
- Worms series
- Angry Birds
- Tank Stars
- ShellShock Live

## Known Issues

### Current Limitations
1. **No persistent collision** - Tanks use simplified collision
2. **Limited visual effects** - Basic colored rectangles and circles
3. **No sound** - Audio not yet implemented
4. **AI pathfinding** - AI doesn't move, only shoots
5. **Shop system** - Not yet implemented (all weapons available)

### Bug Reports
If you encounter issues:
1. Check the Godot console for error messages
2. Verify you're using Godot 4.2 or newer
3. Try restarting the game
4. Report issues with steps to reproduce

## Gameplay Screenshot (ASCII)

```
=================================
  SCORCHED EARTH - Godot Remake
=================================

Wind: → 25
Player 1 [====] vs Player 2 [====]

              💥
           /
    🎮    /
    🟥   /
    ████         🟦🎮
   ██████       ███████
  ███████████████████████
```

## License

This is a fan remake/educational project based on the classic Scorched Earth game.
Not affiliated with or endorsed by the original creators.

For educational and non-commercial use only.

## Version History

### v0.1.0 (2025-11-23)
- Initial implementation
- Core gameplay functional
- 13 weapons implemented
- AI opponents
- Turn-based combat
- Destructible terrain

---

**Enjoy the game! Master the physics and dominate the battlefield!** 🎮💥🚀
