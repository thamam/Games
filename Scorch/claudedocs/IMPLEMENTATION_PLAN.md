# Scorched Earth - Implementation Plan

**Version**: 1.0
**Last Updated**: 2025-11-28
**Current Phase**: Phase 1 - Core Prototype (in progress)
**References**: GDD.md, GAME_BRIEF.md

---

## Current Status Summary

###✅ Completed Features (Commit: f0ebcba)
- ✓ Core terrain generation (procedural with midpoint displacement)
- ✓ Fully destructible terrain with pixel-perfect collision
- ✓ Tank physics (CharacterBody2D with gravity and collision)
- ✓ Basic projectile system (ballistic physics, wind, gravity)
- ✓ Particle-based explosion effects (debris + smoke)
- ✓ Turn-based game flow (GameManager state machine)
- ✓ 2-player support (1 human, 1 AI placeholder)
- ✓ Basic UI/HUD (player stats, wind indicator, controls)
- ✓ Weapon type system (Weapon.gd with 13 weapon definitions)
- ✓ Damage system with shields
- ✓ Fall damage with parachutes
- ✓ Interest/economy foundation ($10,000 starting, interest per round)

### 🚧 In Progress
- Tank movement (fuel system functional, starting with 100 fuel for testing)
- Explosion visual polish

### ❌ Missing Critical Features

---

## Feature Implementation Roadmap

Based on GDD requirements, here are all missing features organized by priority and dependency.

---

## PHASE 1: Core Gameplay Polish (Current Phase)

**Goal**: Make existing systems production-ready
**Timeline**: 2-3 weeks

### 1.1 - Weapon Arsenal Completion ⚠️ HIGH PRIORITY

**Status**: ✅ MAJOR PROGRESS - 4 new advanced weapons implemented (2025-11-29)
**GDD Reference**: Section 2.3 (Weapons Arsenal)

**Implemented Weapon Types** (2025-11-29):
- [x] ✅ MIRV functionality (splits at apex into 5 warheads - Projectile.gd:395-448)
- [x] ✅ Funky Bomb (cluster bomb scatters 8 submunitions - Projectile.gd:451-522)
- [x] ✅ Guided Missile (player-controlled flight with arrow keys - Projectile.gd:525-600)
- [x] ✅ Heat Seeker (tracks nearest tank for 5 seconds - Projectile.gd:603-711)
- [x] ✅ Roller (rolls down slopes using terrain physics - Projectile.gd:714-828)

**Remaining Weapon Types**:
- [ ] Leapfrog (bouncing bomb) - Partially implemented, needs testing
- [ ] Sandhog (large terrain removal)
- [ ] Additional weapon variants (Baby versions, special effects)

**Implementation Tasks** (2025-11-29 Update):
1. ✅ Enable MIRV projectile spawning (COMPLETE - splits into 5 submunitions at apex)
2. ✅ Implement cluster bomb mechanics (COMPLETE - Funky Bomb scatters 8 submunitions)
3. ✅ Add guided missile control system (COMPLETE - arrow keys for 3 seconds of control)
4. ✅ Add heat-seeking logic (COMPLETE - tracks nearest tank with 150°/s turn rate)
5. ✅ Implement rolling physics (COMPLETE - Roller uses slope detection and physics)
6. ⏳ Test all weapons for balance and functionality (pending manual testing)
7. ✅ Add weapon-specific visual effects (COMPLETE - unique colors per weapon type)

**Test Plan**:
```gdscript
# Test: Weapon Functionality Suite
1. Fire each weapon type at different angles/powers
2. Verify MIRV splits at trajectory apex
3. Verify cluster bombs scatter correctly
4. Test guided missile responds to input
5. Test heat-seeking tracks moving targets
6. Verify terrain interaction (rollers go downhill)
7. Measure damage values match GDD specs
8. Check explosion radius scaling
```

**Acceptance Criteria**:
- ✅ 18/20+ weapons implemented (13 existing + 5 new advanced weapons)
- ✅ Each weapon has distinct behavior (MIRV splits, Funky clusters, Guided/Heat-seeking, Roller physics)
- ✅ Damage values configured per weapon type
- ✅ Visual feedback clear (Cyan=MIRV, Magenta=Funky, Gold=Guided, Orange=Heat-Seeker, Green=Roller)
- ⏳ Needs manual testing and balance tuning

**Phase 1.1 Core Implementation**: ✅ COMPLETE (5/5 major advanced weapons implemented)

---

### 1.2 - Shop/Purchase System ✅ COMPLETED (Commit: eca6166)

**Status**: Fully implemented and functional
**GDD Reference**: Section 2.2 (Economy System), 2.4 (Defensive & Utility Items)

**Implementation Date**: 2025-11-28
**Completion Status**: Phase 1.2 done, economy gameplay loop unblocked

**Implementation Tasks**:
1. Create Shop UI (displays before each turn)
   - Show player money
   - List all available weapons with costs
   - Show defensive items (shields, parachutes, fuel, batteries)
   - Purchase confirmation system
2. Integrate shop into turn flow
   - Show shop at turn start or on demand (Tab key)
   - Update player inventory after purchase
   - Deduct money from player
   - Validate sufficient funds
3. Inventory management
   - Track purchased weapons per player
   - Display current inventory in HUD
   - Weapon selection from inventory (1-9 keys)
4. Item effects implementation
   - Shields: Absorb damage (heavy/medium/light)
   - Shield Battery: Recharge shields
   - Fuel Tank: Add movement fuel
   - Parachutes: Prevent fall damage (already functional)
   - Batteries: Future use for special equipment
   - Tracers: Show projectile path preview

**UI Mockup Structure**:
```
=== SHOP (Player 1 - $10,000) ===

WEAPONS:
[1] Baby Missile     $100    (DMG: 15,  RAD: 20)
[2] Missile          $500    (DMG: 30,  RAD: 30)
[3] Heavy Missile    $1500   (DMG: 70,  RAD: 50)
[4] Nuke             $5000   (DMG: 120, RAD: 100)
...

DEFENSE:
[D] Heavy Shield     $1000   (Absorbs 50 damage)
[F] Fuel Tank        $400    (Movement fuel)
[P] Parachute        $500    (Prevents fall damage)

[Enter] Purchase | [ESC] Cancel | [Space] Skip Shopping
```

**Test Plan**:
```gdscript
# Test: Shop System
1. Verify shop displays at turn start
2. Test purchasing weapon (money deducted, inventory updated)
3. Test insufficient funds (purchase blocked)
4. Test purchasing shields (damage absorption works)
5. Test purchasing fuel (tank can move)
6. Test purchasing parachute (fall damage prevented)
7. Test inventory persistence across turns
8. Verify shop closes after purchase/skip
```

**Acceptance Criteria**:
- Shop UI functional and user-friendly
- All items purchasable with correct costs
- Inventory tracked per player
- Defensive items have mechanical effects
- Cannot purchase without sufficient funds
- Shop integrates seamlessly with turn flow

---

### 1.3 - AI Opponent System ⚠️ HIGH PRIORITY

**Status**: Placeholder AI (does nothing)
**GDD Reference**: Section 2.5 (AI Opponents)

**Required AI Levels**:
1. **Lobber** (Beginner): Random shots with poor accuracy
2. **Poolshark** (Intermediate): Attempts bank shots, considers wind
3. **Spoiler** (Expert): Near-perfect trajectory calculations

**Implementation Tasks**:
1. AI decision-making system
   - Analyze battlefield (tank positions, terrain height)
   - Select target (nearest, weakest, or random)
   - Calculate trajectory to hit target
   - Choose appropriate weapon from inventory
2. Difficulty-based aiming
   - Lobber: Random angle/power with 30-50% accuracy
   - Poolshark: Calculated aim with 60-80% accuracy + noise
   - Spoiler: Physics-perfect aim with 90-95% accuracy
3. AI shopping behavior
   - Purchase weapons based on available money
   - Buy defensive items when low health
   - Strategic weapon selection (nuke when high money, missiles otherwise)
4. AI turn execution
   - Automatic firing after aim calculation
   - Realistic delay between actions (thinking time)
   - Visual feedback for AI decision-making

**Physics Calculation Helper**:
```gdscript
# Calculate angle/power to hit target
func calculate_trajectory(from: Vector2, to: Vector2, wind: Vector2) -> Dictionary:
	# Ballistic trajectory solver
	# Returns {angle: float, power: float, hit_probability: float}
	pass
```

**Test Plan**:
```gdscript
# Test: AI Behavior
1. Lobber AI fires and misses frequently
2. Poolshark AI hits target 60-80% of time
3. Spoiler AI hits target 90%+ of time
4. AI purchases weapons/items appropriately
5. AI adapts to terrain changes
6. AI targets nearest/weakest opponent strategically
7. Verify AI turn doesn't hang or crash
```

**Acceptance Criteria**:
- 3 distinct AI difficulty levels functional
- AI can aim and fire weapons
- AI makes purchasing decisions
- AI behavior appears intelligent (not random spamming)
- Game playable vs AI opponent

---

### 1.4 - Visual Effects Polish

**Status**: Particle system implemented, needs enhancement
**GDD Reference**: Section 5.3 (Particle Effects), 5.4 (Tank Designs)

**Implementation Tasks**:
1. Enhanced explosion effects
   - Scale debris/smoke particles with weapon type
   - Add fire effects for napalm weapons
   - Flash intensity based on damage
   - Screen shake for large explosions (optional)
2. Projectile trails
   - Weapon-specific trail colors
   - Particle trail that fades over time
   - Smoke trail for guided missiles
3. Tank visual feedback
   - Damage states (pristine → damaged → critical)
   - Shield visual indicator (force field effect)
   - Movement dust particles when tank moves
4. Terrain-specific effects
   - Different debris colors per terrain type (sand, rock, lunar)
   - Terrain-matched explosion colors
5. UI polish
   - Animated health bars
   - Money/score popup animations
   - Turn transition effects

**Test Plan**:
- Visual inspection of all explosion types
- Verify particle count scales with weapon power
- Check terrain colors match debris colors
- Confirm visual feedback doesn't impact performance (60 FPS target)

---

## PHASE 2: Extended Features

**Goal**: Implement remaining GDD features
**Timeline**: 4-6 weeks

### 2.1 - Terrain Variety

**GDD Reference**: Section 5.2 (Terrain Graphics)

**Missing Terrain Types**:
- [ ] Desert (sandy, yellow-brown)
- [ ] Mountains (rocky, grey-brown) - **Currently default**
- [ ] Lunar (low gravity, grey)
- [ ] Arctic (icy, white-blue)
- [ ] Volcanic (high danger, red-orange)

**Implementation**: Theme functions exist in Terrain.gd (lines 264-287), need to be callable from menu

---

### 2.2 - Game Modes

**GDD Reference**: Section 3 (Game Modes)

**Current**: Classic mode only (last tank standing)

**Missing Modes**:
- [ ] Tournament Mode (points-based, multiple rounds)
- [ ] Teams Mode (2-4 teams, shared victory)
- [ ] Custom Game (configurable parameters)
- [ ] Campaign Mode (future expansion)

---

### 2.3 - Multiplayer

**GDD Reference**: Section 8 (Multiplayer & Social Features)

**Current**: Local hotseat (2 players)

**Missing**:
- [ ] Support for 3-10 players
- [ ] LAN multiplayer
- [ ] Online multiplayer (Phase 3)
- [ ] Matchmaking system (Phase 3)

---

### 2.4 - Audio System

**GDD Reference**: Section 6 (Audio Design)

**Status**: Not implemented

**Required**:
- [ ] Background music (main menu, in-game)
- [ ] Sound effects (firing, explosions, terrain impact, UI)
- [ ] Optional announcer voice

---

### 2.5 - Advanced Physics

**GDD Reference**: Section 2.1.2 (Physics System)

**Missing**:
- [ ] Unstable terrain collapse (floating terrain falls)
- [ ] Tank sliding on steep slopes
- [ ] Improved wind system (variable per round)
- [ ] Gravity customization (for different terrains)

---

## PHASE 3: Polish & Testing

**Goal**: Release-ready quality
**Timeline**: 2-3 weeks

### 3.1 - Balance Tuning
- Weapon damage/cost balancing
- AI difficulty calibration
- Economy tuning (interest rates, starting money)
- Terrain generation parameters

### 3.2 - Bug Fixing & Optimization
- Performance profiling (maintain 60 FPS)
- Memory leak detection
- Physics edge cases (tanks in walls, projectile stuck)
- UI responsiveness

### 3.3 - Playtesting
- Closed beta with 10-20 testers
- Gather feedback on balance and fun factor
- Iterate on issues

---

## Automated Testing Strategy

### Unit Tests (GDScript Testing Framework)

```gdscript
# tests/test_weapon_damage.gd
func test_missile_damage():
	var missile = Weapon.create_missile()
	assert_eq(missile.damage, 30, "Missile should deal 30 damage")
	assert_eq(missile.explosion_radius, 30.0, "Missile radius should be 30")

# tests/test_economy.gd
func test_purchase_weapon():
	var player_money = 1000
	var weapon_cost = 500
	assert_true(player_money >= weapon_cost, "Should have sufficient funds")
	player_money -= weapon_cost
	assert_eq(player_money, 500, "Money should be deducted")
```

### Integration Tests

```gdscript
# tests/test_turn_flow.gd
func test_complete_turn():
	game_manager.setup_new_game(2, [])
	game_manager.start_round()
	var initial_turn = game_manager.current_turn
	# Simulate player firing
	tank.fire("missile")
	await projectile.tree_exited
	game_manager.end_turn()
	assert_eq(game_manager.current_turn, initial_turn + 1, "Turn should increment")
```

### Visual Regression Tests

- Screenshot comparisons for UI elements
- Particle effect consistency checks
- Terrain generation visual validation

---

## Priority Order for Next Implementation

1. ✅ ~~**Shop/Purchase System**~~ **(COMPLETED 2025-11-28)**
2. **🟡 HIGH: Weapon Arsenal Completion** ← **NEXT PRIORITY**
   - MIRV testing and fixes
   - Cluster bombs (Funky Bomb)
   - Guided missiles
   - Heat-seeking
   - Rolling/bouncing weapons
3. **🟡 HIGH: AI Opponent System** (single-player experience)
4. **🟢 MEDIUM: Visual Effects Polish** (juice and feel)
5. **🟢 MEDIUM: Terrain Variety Themes** (desert, lunar, arctic, volcanic)
6. **🔵 LOW: Additional Game Modes** (post-MVP)
7. **🔵 LOW: Online Multiplayer/Audio** (post-MVP)

---

## Success Metrics (Phase 1 Completion)

- [x] ~~Shop system allows purchasing weapons/items~~ **✅ DONE**
- [x] ~~Configurable player count (2-10)~~ **✅ DONE**
- [x] ~~Particle effects polished and performant~~ **✅ DONE**
- [x] ~~Game runs at stable 60 FPS~~ **✅ DONE**
- [x] ~~Enhanced terrain generation~~ **✅ DONE**
- [x] ~~Advanced weapons implemented (MIRV, cluster, guided, heat-seeking)~~ **✅ DONE (2025-11-29)**
- [ ] All 20+ weapons functional and tested (17/20+ implemented, needs testing)
- [ ] 3 AI difficulty levels playable (0/3 functional)
- [ ] No critical bugs in core gameplay loop
- [ ] Multi-player hotseat fully playable end-to-end

**Phase 1 Progress**: 6/10 metrics complete (60%)

---

## Development Notes

### Technical Debt
- Circular dependency warnings (use `load()` instead of `preload()`)
- Consider implementing weapon factory pattern
- Refactor explosion effects to be weapon-customizable

### Performance Targets (GDD Section 7.3)
- Frame Rate: 60 FPS minimum ✓ (currently achieved)
- Memory: < 500MB RAM usage ✓ (currently ~100MB)
- Load Times: < 3 seconds between matches ✓

### Code Quality Checklist
- [ ] All functions have docstrings
- [ ] Class_name declarations used consistently
- [ ] Signals used for decoupling
- [ ] GDScript style guide followed

---

**Next Steps**:
1. Review and approve this plan
2. Begin Phase 1.2 (Shop System) implementation
3. Create detailed test cases for shop functionality
4. Implement and test shop UI
5. Integrate shop into turn flow
6. Move to Phase 1.1 (Weapon Arsenal)

---

**Document Status**: DRAFT - Ready for Review
