# Scorched Earth - Quick Start Guide

Get playing in under 5 minutes!

## Installation

### Step 1: Install Godot
Download Godot 4.2+ from: https://godotengine.org/download

### Step 2: Open Project
1. Launch Godot
2. Click **"Import"**
3. Navigate to the `ScorchedEarth` folder
4. Select `project.godot`
5. Click **"Import & Edit"**

### Step 3: Play!
Press **F5** or click the **Play** button (▶️)

## How to Play

### Objective
Destroy all enemy tanks to win!

### Basic Controls
```
🎯 Aim:      ← → Arrow Keys (adjust angle)
⚡ Power:    ↑ ↓ Arrow Keys (adjust power)
🚀 Fire:     SPACE
🚶 Move:     A / D (requires fuel)
🔫 Weapons:  1-9 (quick select)
```

### Your First Turn

1. **Check the Wind**
   - Look at top of screen: `Wind: → 25` means wind blowing right
   - Adjust your aim to compensate

2. **Aim Your Cannon**
   - Press ← → to adjust angle (0-180°)
   - Angle shown in status: `Angle: 45°`

3. **Set Power**
   - Press ↑ ↓ to adjust power (0-100%)
   - Higher power = farther distance

4. **Fire!**
   - Press SPACE to launch
   - Watch the physics magic happen! 💥

### Tips for New Players

#### 🎯 Aiming Guide
- **45°** = Maximum range
- **High angle (60-80°)** = Arc over obstacles
- **Low angle (20-40°)** = Fast, direct shot

#### 💨 Wind Compensation
- **Wind →** (right): Aim slightly left
- **Wind ←** (left): Aim slightly right
- **Strong wind**: Adjust more!

#### 💰 Money Management
- You start with **$10,000**
- Each weapon has a cost
- Earn interest on savings each round
- Get bonus for kills

#### 🛡️ Survival Tips
1. **Don't bunch up** - Explosions hit nearby tanks
2. **Watch fall damage** - Big drops hurt!
3. **Use terrain** - Hide behind hills
4. **Buy shields** - Protect yourself (future feature)

## Weapon Guide

### Beginner Weapons
| Weapon | Cost | Use When |
|--------|------|----------|
| **Baby Missile** | $100 | Learning to aim |
| **Missile** | $500 | Standard shot (DEFAULT) |
| **Heavy Missile** | $1,500 | Need more damage |

### Advanced Weapons
| Weapon | Cost | Special Feature |
|--------|------|----------------|
| **MIRV** | $3,000 | Splits into 5 warheads! |
| **Nuke** | $5,000 | Massive explosion |
| **Funky Bomb** | $2,000 | Bounces chaotically |
| **Roller** | $800 | Rolls down slopes |

### Terrain Weapons
| Weapon | Cost | Effect |
|--------|------|--------|
| **Dirt Ball** | $200 | Adds terrain (bury enemies!) |
| **Dirt Charge** | $300 | Removes terrain (create holes!) |

## Quick Reference

### HUD Display
```
=== Player 1's Turn ===
Player 1 | Health: 100 | Money: $10000 | Shields: 0
Wind: → 15
Angle: 45° | Power: 50% | Health: 100 | Shields: 0 | Fuel: 0
```

### Game Flow
```
Round Start
    ↓
Player 1 Turn → Fire → Explosion → Damage
    ↓
Player 2 Turn → Fire → Explosion → Damage
    ↓
Round End (if no winner)
    ↓
New Round (earn interest)
    ↓
Repeat until one tank remains!
```

## Common Questions

**Q: How do I buy weapons?**
A: Currently all weapons are available! Press 1-9 to select. (Shop system coming soon)

**Q: Why can't I move?**
A: You need fuel! (Fuel system implemented but requires shop to purchase)

**Q: How do I beat the AI?**
A: Practice aiming! The AI calculates shots mathematically, but you can outsmart it with terrain and strategy.

**Q: Can I play with friends?**
A: Not yet in this version - local multiplayer coming soon!

**Q: The game crashed!**
A: Check the Godot console for errors. Make sure you're using Godot 4.2+

**Q: How do I restart?**
A: Press **R** when the game is over, or **F5** to restart completely

## Advanced Techniques

### Bank Shots
Use **Funky Bomb** or **Napalm** to bounce projectiles around obstacles!

### MIRV Mastery
1. Aim **high** (60-80°)
2. High power (70-90%)
3. Watch it split at the apex
4. 5 warheads rain down! 💥💥💥💥💥

### Terrain Tactics
1. **Dirt Ball** - Bury enemy tanks under terrain
2. **Dirt Charge** - Remove ground beneath enemies (they fall and take damage!)
3. **Strategic Cover** - Create hills to hide behind

### Wind Tricks
- **Strong headwind**: Add 10-15° to your angle
- **Tailwind**: Reduce angle by 10-15°
- **MIRV in wind**: Each sub-munition is affected differently!

## Performance Tips

### If game is laggy:
1. Close other applications
2. Reduce window size
3. Check Godot console for errors

### If terrain looks weird:
Restart the game (F5) - terrain is procedurally generated each time

## Next Steps

Once you've mastered the basics:
1. Try different weapons
2. Experiment with terrain modification
3. Challenge yourself against harder AI
4. Check out the full README.md for technical details
5. Contribute new features!

## Have Fun!

Remember: It's all about **physics, strategy, and explosions**! 🚀💥

**Pro tip**: The best way to learn is to experiment. Try every weapon, test every angle, and most importantly - enjoy the chaos!

---

Need more help? Check **README.md** for full documentation.

Found a bug? Want a feature? Open an issue on GitHub!

**Now go forth and SCORCH THE EARTH!** 🔥🌍💣
