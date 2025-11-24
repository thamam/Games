# Scorched Earth Project

A modern remake of the classic 1991 DOS artillery game **Scorched Earth**.

## Project Contents

### 📋 Documentation
- **[GDD.md](GDD.md)** - Complete Game Design Document
- **[GAME_BRIEF.md](GAME_BRIEF.md)** - Executive Game Brief and Project Overview

### 🎮 Game Implementation
- **[ScorchedEarth/](ScorchedEarth/)** - Godot 4 game implementation
  - Full playable game with 13+ weapons
  - Destructible terrain with physics simulation
  - AI opponents with multiple difficulty levels
  - Turn-based artillery combat

## Quick Start

### Play the Game
```bash
cd ScorchedEarth
# Open in Godot 4.2+ and press F5
```

See **[ScorchedEarth/QUICKSTART.md](ScorchedEarth/QUICKSTART.md)** for detailed instructions.

### Read the Design Docs
- Start with **[GAME_BRIEF.md](GAME_BRIEF.md)** for overview
- Read **[GDD.md](GDD.md)** for complete design details

## Features Implemented

✅ **Core Gameplay**
- Procedural terrain generation
- Pixel-perfect destructible terrain
- Physics-based ballistics (wind, gravity)
- Turn-based combat system

✅ **Weapons (13+)**
- Basic missiles (Baby, Standard, Heavy, Nuke)
- Special weapons (MIRV, Funky Bomb, Napalm, Roller)
- Dirt manipulation (Dirt Ball, Dirt Charge, Dirt Slapper)

✅ **Game Systems**
- AI opponents (3 difficulty levels)
- Damage and health system
- Wind mechanics
- Fall damage
- Tank movement with fuel
- Economy system (money, interest)

✅ **Technical**
- Built with Godot 4.2
- Modular weapon system
- Extensible architecture
- Cross-platform support

## Project Structure

```
Scorch/
├── GDD.md                  # Game Design Document
├── GAME_BRIEF.md          # Project Brief
├── README.md              # This file
└── ScorchedEarth/         # Game implementation
    ├── project.godot      # Godot project file
    ├── README.md          # Game documentation
    ├── QUICKSTART.md      # Quick start guide
    ├── scenes/            # Game scenes
    │   └── Main.tscn     # Main game scene
    ├── scripts/           # GDScript files
    │   ├── GameManager.gd
    │   ├── Terrain.gd
    │   ├── Tank.gd
    │   ├── Projectile.gd
    │   ├── Weapon.gd
    │   └── Main.gd
    └── assets/            # Game assets (sprites, sounds, music)
```

## Technology Stack

- **Engine**: Godot 4.2
- **Language**: GDScript
- **Platform**: Cross-platform (Windows, macOS, Linux)
- **Physics**: Custom 2D ballistics simulation

## Development Status

**Version**: 0.1.0 (Alpha)
**Status**: Playable prototype with core features

### Completed ✅
- [x] Game design documentation
- [x] Core gameplay implementation
- [x] Terrain generation and destruction
- [x] Weapons system (13+ weapons)
- [x] AI opponents
- [x] Turn management
- [x] Basic UI

### Planned 📋
- [ ] Shop/purchasing interface
- [ ] Enhanced visual effects
- [ ] Sound and music
- [ ] Main menu
- [ ] Multiplayer (local/online)
- [ ] Additional game modes
- [ ] More weapons and features

## How to Contribute

1. Read the GDD and Game Brief
2. Check the game implementation
3. Open issues for bugs or feature requests
4. Submit pull requests for improvements

## Credits

### Original Game
**Scorched Earth** (1991) by Wendell Hicken

### This Remake
- **Design**: Based on original Scorched Earth
- **Implementation**: Godot 4 GDScript
- **Year**: 2025

## License

Educational/Fan project. Not for commercial use.
Based on the classic Scorched Earth game.

---

**Ready to play?** → See [ScorchedEarth/QUICKSTART.md](ScorchedEarth/QUICKSTART.md)

**Want details?** → See [GDD.md](GDD.md) and [GAME_BRIEF.md](GAME_BRIEF.md)

**Enjoy the game!** 🎮💥🚀
