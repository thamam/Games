# Weapon Testing Guide

**Purpose**: Manual testing procedures for all weapon types

**Date**: 2025-11-29

---

## Phase 1.1 - Weapon Arsenal Testing

### MIRV (Multi-Independently targeted Reentry Vehicle)

**Status**: ✅ Code complete, needs manual testing

**Implementation**: Projectile.gd:395-448 (MIRVProjectile class)

**Properties**:
- Cost: $3,000
- Damage: 25 per submunition
- Explosion Radius: 25.0
- Submunition Count: 5
- Color: Cyan

**Expected Behavior**:
1. Fires as single cyan projectile
2. At trajectory apex (when velocity.y > 0), splits into 5 warheads
3. Submunitions spread in 120° fan pattern (-60° to +60°)
4. Each submunition inherits 30% of parent velocity + spread velocity
5. Parent projectile is removed after split (queue_free)
6. Each submunition explodes independently on terrain impact

**Edge Cases Handled**:
- If MIRV hits terrain before apex → explodes normally (no split)
- If MIRV already exploded → won't split (defensive check)

**Test Procedure**:
```
1. Start game
2. Press TAB → Shop
3. Purchase "MIRV" ($3000)
4. Press "6" to select MIRV weapon
5. Aim at ~45° angle with high power (0.8+)
6. Press SPACE to fire
7. Watch for console: "MIRV splitting into 5 warheads!"
8. Observe 5 cyan projectiles spreading mid-flight
9. Verify each creates separate explosion
10. Verify total terrain destruction from 5 impacts
```

**Console Output Expected**:
```
Tank 0 fired mirv
Projectile launched at X,Y with velocity VX,VY
MIRV splitting into 5 warheads!
💥 Projectile exploded at X1,Y1
💥 Projectile exploded at X2,Y2
... (5 total explosions)
```

---

### Funky Bomb (Cluster Bomb)

**Status**: 🚧 Partially implemented, needs cluster mechanics

**Implementation**: Weapon definition exists (Weapon.gd:157-169), needs cluster logic

**Properties**:
- Cost: $2,000
- Damage: 20 per submunition
- Explosion Radius: 25.0
- Bounces: 3
- Bounce Factor: 0.7
- Color: Magenta

**Expected Behavior** (TO IMPLEMENT):
1. Fires as single magenta projectile
2. Bounces up to 3 times with 70% velocity retention
3. On final impact OR after 3 bounces → splits into cluster
4. Cluster submunitions scatter randomly in all directions
5. Each submunition explodes after short delay (0.1-0.3s)

**Implementation Plan**:
- [ ] Create FunkyBombProjectile class extending Projectile
- [ ] Add cluster split logic (similar to MIRV but on final bounce)
- [ ] Random scatter pattern (360° spread)
- [ ] Short fuse timer for submunitions
- [ ] Test chaotic explosion pattern

---

### Roller (Rolling Bomb)

**Status**: ✅ Code complete, needs testing

**Implementation**: Projectile.gd:714-828 (RollerProjectile class)

**Properties**:
- Cost: $800
- Damage: 40
- Explosion Radius: 30.0
- Gravity Scale: 2.0 (heavy)
- Bounces: 5
- Bounce Factor: 0.8
- Color: Green

**Behavior**:
1. Fires as green projectile with 2x gravity
2. After first bounce → starts rolling mode
3. Detects terrain slope using surface normal
4. Applies rolling force down slopes (faster on steeper slopes)
5. Slope factor: sin(slope_angle) × 200 × 1.5 multiplier
6. Bounces up to 5 times while rolling
7. Explodes when velocity drops below 50 units/s OR max bounces
8. Damping (0.95) prevents infinite acceleration

**Test Procedure**:
```
1. Purchase Roller ($800) from shop
2. Fire at mountainous terrain with slopes
3. Watch projectile bounce and start rolling
4. Observe it accelerate down slopes
5. Verify it slows down on flat/uphill terrain
6. Confirm explosion after stopping or max bounces
```

---

### Leapfrog (Bouncing Bomb)

**Status**: 🚧 Partially implemented, needs tuning

**Implementation**: Weapon definition exists (Weapon.gd:200-212)

**Properties**:
- Cost: $1,200
- Damage: 45
- Explosion Radius: 35.0
- Bounces: 4
- Bounce Factor: 0.75
- Color: Lime

**Expected Behavior**:
1. Fires as lime projectile
2. Bounces 4 times with 75% velocity retention
3. Each bounce has similar height/distance
4. Explodes after 4th bounce or terrain impact

**Test Procedure**:
```
1. Purchase Leapfrog ($1200)
2. Press "9" to select
3. Fire at shallow angle (20-30°)
4. Count bounces (should be ~4)
5. Verify explosion after final bounce
```

---

## Next Weapons to Implement

### High Priority (Phase 1.1):
- **Funky Bomb**: Cluster mechanics needed
- **Guided Missile**: Player-controlled flight (arrow keys during flight)
- **Heat-Seeking**: Track nearest tank, adjust trajectory
- **Sandhog**: Large terrain removal (GDD Section 2.3)

### Existing Working Weapons:
1. Baby Missile (Key "1") - $100
2. Missile (Key "2") - $500 ✅ DEFAULT
3. Heavy Missile (Key "3") - $1,500
4. Baby Nuke (Key "4") - $2,500
5. Nuke (Key "5") - $5,000 (with shockwaves)
6. MIRV (Key "6") - $3,000 (needs testing)
7. Funky Bomb (Key "7") - $2,000 (needs cluster logic)
8. Napalm (Key "8") - $1,800 (bounces 2x)
9. Roller (Key "9") - $800 (needs rolling physics)

### Dirt Weapons (No number key, shop only):
10. Leapfrog - $1,200 (bounces 4x)
11. Dirt Ball - $200 (adds terrain)
12. Dirt Slapper - $500 (large dirt deposit)
13. Dirt Charge - $300 (removes terrain)

---

**Testing Status**: 1/13 weapons fully tested (Phase 1 target: 20+ weapons)

**Next Steps**:
1. Manual test MIRV
2. Implement Funky Bomb cluster mechanics
3. Implement Guided Missile control system
4. Implement Heat-Seeking logic
5. Implement Roller rolling physics

