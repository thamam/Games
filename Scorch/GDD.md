# Scorched Earth - Game Design Document (GDD)

## Version Control
- **Document Version:** 1.0
- **Last Updated:** November 23, 2025
- **Game Title:** Scorched Earth Remake
- **Genre:** Artillery, Turn-Based Strategy
- **Platform:** PC (Cross-platform potential)
- **Target Audience:** Ages 10+, Strategy and Physics enthusiasts

---

## 1. Executive Summary

### 1.1 Game Concept
Scorched Earth is a turn-based artillery strategy game where players control tanks positioned on destructible terrain. Players must eliminate their opponents by calculating precise trajectories, accounting for wind, gravity, and terrain obstacles while managing limited resources and strategic weapon choices.

### 1.2 Core Gameplay Loop
1. **Purchase Phase:** Players buy weapons, shields, and utilities with limited funds
2. **Targeting Phase:** Select weapon, adjust angle and power
3. **Execution Phase:** Fire weapon considering physics (wind, gravity, terrain)
4. **Resolution Phase:** Damage is dealt, terrain is destroyed, turn passes
5. **Repeat** until only one player remains

### 1.3 Unique Selling Points (USPs)
- Fully destructible terrain with realistic physics
- Extensive arsenal of over 20+ unique weapons
- Support for up to 10 simultaneous players (human and AI)
- Deep strategic gameplay combining resource management and physics
- Emergent gameplay through terrain destruction

---

## 2. Gameplay Mechanics

### 2.1 Core Mechanics

#### 2.1.1 Turn Structure
- **Turn Order:** Sequential, clockwise from Player 1
- **Time Limit:** Optional (30-120 seconds per turn)
- **Actions Per Turn:**
  - Purchase equipment (first turn and between rounds)
  - Set tank angle (0-180 degrees)
  - Set firing power (0-100%)
  - Select weapon from inventory
  - Fire weapon

#### 2.1.2 Physics System
- **Projectile Physics:**
  - Realistic ballistic trajectories
  - Wind affects all projectiles (variable strength and direction)
  - Gravity constant (adjustable in settings)
  - Collision detection with terrain and tanks

- **Terrain Deformation:**
  - All weapons create craters/terrain changes
  - Dirt can be added or removed
  - Tanks slide down steep slopes
  - Unstable terrain can collapse

#### 2.1.3 Damage System
- **Direct Damage:** Contact with projectile or explosion radius
- **Splash Damage:** Decreases with distance from impact
- **Tank Health:** 100 HP default (adjustable)
- **Shield System:** Absorbs damage, can be recharged
- **Fall Damage:** Tanks take damage from long falls

### 2.2 Economy System

#### 2.2.1 Starting Funds
- Default: $10,000 per player
- Configurable in game settings

#### 2.2.2 Income Sources
- **Interest:** Earn percentage of banked money each round
- **Kill Bonus:** Reward for eliminating opponents
- **Survival Bonus:** Bonus for surviving rounds

#### 2.2.3 Expenditures
- Weapons (varying costs)
- Defensive equipment
- Utilities and movement tools

### 2.3 Weapons Arsenal

#### 2.3.1 Basic Weapons
| Weapon | Cost | Description | Damage |
|--------|------|-------------|--------|
| Baby Missile | $100 | Small, cheap projectile | 10-20 |
| Missile | $500 | Standard projectile | 30-40 |
| Heavy Missile | $1,500 | Large explosive | 60-80 |
| Nuke | $5,000 | Massive destruction | 100+ |
| Baby Nuke | $2,500 | Medium nuclear weapon | 70-90 |

#### 2.3.2 Special Weapons
| Weapon | Cost | Description | Effect |
|--------|------|-------------|--------|
| MIRV | $3,000 | Multiple Independent Reentry Vehicles | Splits into 5 smaller warheads |
| Funky Bomb | $2,000 | Chaotic cluster bomb | Scatters 10+ bombs randomly |
| Napalm | $1,800 | Incendiary weapon | Burns and bounces |
| Death's Head | $7,500 | Ultra-powerful explosive | Devastating blast |
| Roller | $800 | Rolling bomb | Rolls down slopes to target |
| Leapfrog | $1,200 | Bouncing bomb | Multiple bounces before detonation |

#### 2.3.3 Dirt Weapons
| Weapon | Cost | Description | Effect |
|--------|------|-------------|--------|
| Dirt Ball | $200 | Adds terrain | Creates small mound |
| Dirt Slapper | $500 | Large dirt deposit | Buries targets |
| Dirt Charge | $300 | Removes terrain | Creates hole/crater |
| Sandhog | $700 | Tunneling weapon | Removes large terrain section |

#### 2.3.4 Guided Weapons
| Weapon | Cost | Description | Effect |
|--------|------|-------------|--------|
| Hot Napalm | $2,500 | Heat-seeking napalm | Tracks nearest tank |
| Riot Bomb | $3,500 | Guided MIRV | Heat-seeking cluster bomb |
| Guided Missile | $2,000 | Player-controlled | Manual guidance system |

### 2.4 Defensive & Utility Items

#### 2.4.1 Shields
- **Heavy Shield:** $1,000 - Absorbs 50 damage
- **Medium Shield:** $500 - Absorbs 25 damage
- **Light Shield:** $250 - Absorbs 10 damage
- **Shield Battery:** $750 - Recharges shields

#### 2.4.2 Utilities
- **Parachute:** $500 - Prevents fall damage (single use)
- **Fuel Tank:** $400 - Allows tank movement (limited fuel)
- **Batteries:** $300 - Powers special equipment
- **Tracers:** $100 - Shows projectile path for aiming assistance

### 2.5 AI Opponents

#### 2.5.1 AI Difficulty Levels
- **Lobber:** Beginner - Random shots with poor accuracy
- **Poolshark:** Intermediate - Attempts bank shots and ricochets
- **Spoiler:** Expert - Near-perfect calculations and accuracy
- **Custom AI:** Adjustable parameters for custom difficulty

---

## 3. Game Modes

### 3.1 Classic Mode
- Standard gameplay with full weapon arsenal
- 2-10 players (human or AI)
- Last tank standing wins

### 3.2 Tournament Mode
- Multiple rounds with scoring system
- Points awarded for:
  - Kills
  - Damage dealt
  - Survival
  - Accuracy
- Winner has highest score after set rounds

### 3.3 Teams Mode
- Players divided into 2-4 teams
- Shared victory condition
- Optional friendly fire

### 3.4 Campaign Mode (Future)
- Series of progressively difficult challenges
- Unlock weapons and abilities
- Story-driven scenarios

### 3.5 Custom Game
- Fully customizable parameters:
  - Starting money
  - Wind settings
  - Gravity
  - Tank health
  - Available weapons
  - Terrain type

---

## 4. User Interface & Controls

### 4.1 Main Menu
- **New Game** - Start single player or multiplayer
- **Settings** - Configure game options
- **Controls** - View/customize controls
- **Credits** - Development team
- **Exit** - Quit game

### 4.2 In-Game HUD
- **Top Bar:**
  - Current player indicator
  - Wind speed and direction
  - Round number
- **Side Panel:**
  - Player stats (health, money, shields)
  - Weapon inventory
  - Current angle and power
- **Bottom Bar:**
  - Player order and status
  - Mini-map (optional)

### 4.3 Control Scheme

#### Keyboard Controls
- **Left/Right Arrow:** Adjust angle
- **Up/Down Arrow:** Adjust power
- **1-9:** Quick-select weapons
- **Space:** Fire weapon
- **A/D:** Move tank (with fuel)
- **Tab:** Cycle through weapons
- **Enter:** Confirm purchase
- **Esc:** Pause menu

#### Mouse Controls
- **Click and Drag:** Set angle and power
- **Right Click:** Open weapon menu
- **Scroll Wheel:** Cycle weapons
- **Click:** Select/fire

---

## 5. Art & Visual Design

### 5.1 Art Style
- **Visual Direction:** Modern pixel art with smooth animations
- **Inspiration:** Enhanced DOS aesthetic with modern polish
- **Color Palette:** Vibrant but not overwhelming, distinct team colors

### 5.2 Terrain Graphics
- **Procedurally Generated:** Each match has unique terrain
- **Terrain Types:**
  - Desert (sandy, yellow-brown)
  - Mountains (rocky, grey-brown)
  - Lunar (low gravity, grey)
  - Arctic (icy, white-blue)
  - Volcanic (high danger, red-orange)

### 5.3 Particle Effects
- **Explosions:** Dynamic, scale based on weapon
- **Debris:** Flying dirt and rocks
- **Smoke Trails:** Projectile paths
- **Fire Effects:** Napalm and burning terrain

### 5.4 Tank Designs
- Customizable tank colors per player
- Visual indicators for shields (force field effect)
- Damage states (pristine → damaged → critical)
- Distinct silhouettes for easy identification

---

## 6. Audio Design

### 6.1 Music
- **Main Menu:** Upbeat, strategic theme
- **In-Game:** Subtle, non-intrusive background music
- **Victory:** Triumphant fanfare
- **Defeat:** Somber but brief

### 6.2 Sound Effects
- **Weapon Firing:** Distinct sound per weapon type
- **Explosions:** Varied based on weapon power
- **Terrain Impact:** Different sounds for different terrain types
- **UI Feedback:** Click, confirm, error sounds
- **Tank Movement:** Engine sounds when moving
- **Shield Effects:** Energy hum and impact sounds

### 6.3 Voice/Announcer (Optional)
- Round announcements
- Player turn indicators
- Elimination notifications
- Special events (perfect shot, near miss)

---

## 7. Technical Specifications

### 7.1 Target Platforms
- **Primary:** Windows, Linux, macOS
- **Secondary:** Web browser (HTML5)
- **Future:** Mobile (iOS/Android)

### 7.2 Engine & Technology
- **Engine Options:**
  - Unity (cross-platform, robust)
  - Godot (open-source, 2D-focused)
  - Custom engine (full control, more work)
- **Physics:** 2D physics engine with custom ballistics
- **Networking:** Peer-to-peer or server-based multiplayer

### 7.3 Performance Targets
- **Frame Rate:** 60 FPS minimum
- **Resolution:** Support for 1920x1080 and higher
- **Load Times:** < 3 seconds between matches
- **Memory:** < 500MB RAM usage

### 7.4 System Requirements (Estimated)

#### Minimum
- OS: Windows 7/8/10/11
- Processor: Intel Core i3 or equivalent
- Memory: 2 GB RAM
- Graphics: Integrated graphics
- Storage: 200 MB available space

#### Recommended
- OS: Windows 10/11
- Processor: Intel Core i5 or equivalent
- Memory: 4 GB RAM
- Graphics: Dedicated GPU
- Storage: 500 MB available space

---

## 8. Multiplayer & Social Features

### 8.1 Multiplayer Modes
- **Local Hotseat:** 2-10 players on one device
- **LAN:** Local network play
- **Online:** Internet matchmaking
- **Pass-and-Play:** Mobile-style turn passing

### 8.2 Matchmaking
- **Quick Match:** Auto-match with similar skill players
- **Custom Lobby:** Create/join custom games
- **Friends List:** Invite specific players
- **Ranked Mode:** Competitive with ELO rating

### 8.3 Social Features
- **Statistics Tracking:**
  - Total kills
  - Win/loss ratio
  - Favorite weapon
  - Accuracy percentage
  - Total damage dealt
- **Achievements:** Unlock special accomplishments
- **Leaderboards:** Global and friend rankings
- **Replays:** Save and share epic moments

---

## 9. Progression & Retention

### 9.1 Unlockables
- **Cosmetics:**
  - Tank skins
  - Explosion effects
  - Terrain themes
  - Victory animations
- **Gameplay:**
  - New weapons (campaign mode)
  - AI opponents
  - Game modifiers

### 9.2 Skill Progression
- Learning curve from basic to advanced tactics
- Tutorial system teaching:
  - Basic aiming
  - Wind compensation
  - Advanced techniques (bank shots, MIRV timing)
  - Economy management

---

## 10. Monetization (Optional)

### 10.1 Business Model Options
- **Premium:** One-time purchase
- **Free-to-Play:** Free base game with cosmetic purchases
- **Freemium:** Free demo, paid full version

### 10.2 Potential Revenue Streams
- **Cosmetic DLC:** Tank skins, effects, themes
- **Campaign Expansions:** Additional story content
- **Season Pass:** New content over time

---

## 11. Development Roadmap

### 11.1 Phase 1 - Core Prototype (Months 1-2)
- Basic terrain generation
- Simple projectile physics
- 2-player hotseat mode
- 5 basic weapons

### 11.2 Phase 2 - Feature Complete (Months 3-5)
- Full weapon arsenal
- AI opponents
- Economy system
- UI/UX polish

### 11.3 Phase 3 - Polish & Testing (Months 6-7)
- Audio implementation
- Visual effects
- Balance tuning
- Bug fixing
- Playtesting

### 11.4 Phase 4 - Launch & Post-Launch (Month 8+)
- Marketing and release
- Community feedback
- Patches and updates
- DLC/expansions

---

## 12. Success Metrics

### 12.1 Key Performance Indicators (KPIs)
- **Player Retention:**
  - Day 1: 50%
  - Day 7: 30%
  - Day 30: 15%
- **Average Session Length:** 20-30 minutes
- **User Rating:** 4.0+ stars
- **Sales Target:** 10,000+ units in first year (if premium)

### 12.2 Quality Metrics
- **Bug Density:** < 1 critical bug per 1000 lines of code
- **Crash Rate:** < 0.1%
- **User Satisfaction:** 80%+ positive reviews

---

## 13. Risks & Mitigation

### 13.1 Technical Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Physics instability | High | Medium | Extensive testing, physics engine selection |
| Performance issues | Medium | Low | Optimization passes, profiling |
| Network latency | Medium | Medium | Client-side prediction, lag compensation |

### 13.2 Design Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Balance issues | Medium | High | Regular playtesting, data analysis |
| Shallow gameplay | High | Low | Depth through weapon variety and skill ceiling |
| Poor AI | Medium | Medium | Iterative AI development, tuning |

### 13.3 Market Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Low audience interest | High | Medium | Marketing, unique features, nostalgia appeal |
| Competition | Medium | High | Quality differentiation, community building |
| Piracy | Low | Medium | Fair pricing, value proposition |

---

## 14. Appendices

### 14.1 Glossary
- **Artillery Game:** Turn-based game where players fire projectiles
- **MIRV:** Multiple Independently-targetable Reentry Vehicle
- **Hotseat:** Multiplayer mode where players take turns on same device
- **Ballistics:** Physics of projectile motion

### 14.2 References
- Original Scorched Earth (1991) by Wendell Hicken
- Artillery game genre conventions
- Modern physics-based games

### 14.3 Revision History
| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | Nov 23, 2025 | Initial GDD creation | Development Team |

---

**END OF DOCUMENT**
