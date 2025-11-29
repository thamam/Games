# Scorch - Phase 2 Implementation Plan

**Version**: 1.0
**Created**: 2025-11-29
**Phase Duration**: 4-6 weeks (estimated)
**Starting Phase 1 Completion**: 95%

---

## Phase 2 Overview

**Goal**: Extend gameplay variety and replay value through terrain themes, game modes, and enhanced multiplayer

**Focus Areas**:
1. Terrain variety (5 themes with unique visuals/physics)
2. Game modes (Tournament, Teams, Custom)
3. Enhanced multiplayer (3-10 players)
4. Audio system (music, SFX)
5. Advanced physics (terrain collapse, tank sliding)

---

## Priority Ranking

### 🟢 HIGH PRIORITY (Must-Have for Phase 2)
1. **Terrain Variety** - Quick win, big visual impact
2. **Game Mode: Tournament** - Adds replayability
3. **Enhanced Multiplayer** - 3-10 players (already mostly supported)

### 🟡 MEDIUM PRIORITY (Should-Have)
4. **Game Mode: Teams** - Strategic depth
5. **Audio System** - Polish and feel
6. **Main Menu System** - Navigation and settings

### 🔵 LOW PRIORITY (Nice-to-Have)
7. **Advanced Physics** - Terrain collapse, sliding
8. **Game Mode: Campaign** - Future expansion
9. **Custom Game Settings** - Advanced configuration

---

## Task Breakdown

### 2.1 - Terrain Variety 🟢 HIGH (Week 1)

**Status**: Foundation exists in Terrain.gd:267-291
**Effort**: 1 week
**GDD Reference**: Section 5.2 (Terrain Graphics)

#### Implementation Tasks

**Step 1: Terrain Theme Selection UI** (2 days)
- [ ] Create terrain selection menu (before game start)
- [ ] Display theme previews (small terrain samples)
- [ ] Show theme properties (gravity modifier, name, description)
- [ ] Integrate into game setup flow

**Step 2: Enhance Existing Theme Functions** (2 days)
- [ ] **Desert Theme** (Terrain.gd:269-273)
  - Color: Sandy yellow (0.93, 0.79, 0.55)
  - Sky: Light blue (0.53, 0.81, 0.92)
  - Physics: Normal gravity
  - Special: Smoother terrain (less roughness)

- [ ] **Mountains Theme** (Terrain.gd:275-279) - DEFAULT
  - Color: Grey (0.5, 0.5, 0.5)
  - Sky: Sky blue (0.3, 0.5, 0.8)
  - Physics: Normal gravity
  - Special: Current default

- [ ] **Lunar Theme** (Terrain.gd:281-285)
  - Color: Dark grey (0.4, 0.4, 0.4)
  - Sky: Dark space (0.05, 0.05, 0.1)
  - Physics: **Low gravity** (490 vs 980)
  - Special: Add stars to background

- [ ] **Arctic Theme** (NEW)
  - Color: Icy white-blue (0.9, 0.95, 1.0)
  - Sky: Pale blue (0.7, 0.85, 0.95)
  - Physics: Normal gravity
  - Special: Add snow particles

- [ ] **Volcanic Theme** (Terrain.gd:287-291)
  - Color: Dark red (0.3, 0.1, 0.1)
  - Sky: Orange haze (0.4, 0.2, 0.1)
  - Physics: Normal gravity
  - Special: Glowing lava effect, periodic damage zones

**Step 3: Physics Integration** (1 day)
- [ ] Add gravity modifier to terrain themes
- [ ] Update ProjectSettings based on selected theme
- [ ] Test projectile behavior on lunar theme (low gravity)

**Step 4: Visual Enhancements** (2 days)
- [ ] Add theme-specific particle effects
- [ ] Arctic: Snow particles in background
- [ ] Volcanic: Lava glow/heat shimmer
- [ ] Lunar: Stars in space background
- [ ] Desert: Sand dust particles

**Acceptance Criteria**:
- ✅ 5 terrain themes selectable from menu
- ✅ Each theme has distinct visual appearance
- ✅ Lunar theme has reduced gravity (50% of normal)
- ✅ Theme-specific visual effects implemented
- ✅ No performance degradation

---

### 2.2 - Tournament Mode 🟢 HIGH (Week 2)

**Effort**: 1 week
**GDD Reference**: Section 3.2 (Tournament Mode)

#### Implementation Tasks

**Step 1: Scoring System** (2 days)
- [ ] Create TournamentManager.gd script
- [ ] Track points per player:
  - Kills: 100 points
  - Damage dealt: 1 point per HP
  - Survival: 50 points per round survived
  - Accuracy: Bonus for high hit rate
- [ ] Display score table between rounds

**Step 2: Multi-Round Structure** (2 days)
- [ ] Configure number of rounds (3, 5, 7, or custom)
- [ ] Reset tanks/terrain between rounds (keep scores)
- [ ] Show round number and standings
- [ ] Declare winner after final round (highest score)

**Step 3: Tournament UI** (2 days)
- [ ] Create score display HUD element
- [ ] Round transition screen with standings
- [ ] Final scoreboard with winner announcement
- [ ] Statistics summary (total kills, damage, accuracy)

**Step 4: Testing** (1 day)
- [ ] Test 3-round tournament with 4 players
- [ ] Verify scoring calculations correct
- [ ] Test tie-breaking (most kills, then damage)

**Acceptance Criteria**:
- ✅ Tournament mode playable with configurable rounds
- ✅ Points awarded correctly
- ✅ Scoreboard displays between rounds
- ✅ Winner determined by total score

---

### 2.3 - Enhanced Multiplayer (3-10 Players) 🟢 HIGH (Week 2-3)

**Status**: Already supports 2-10 players (Main.gd:129)
**Effort**: 3 days (polish and testing)
**GDD Reference**: Section 8 (Multiplayer & Social Features)

#### Implementation Tasks

**Step 1: Player Setup UI** (1 day)
- [ ] Create player configuration screen
- [ ] Set player names (Player 1, Player 2, etc.)
- [ ] Choose human vs AI per player
- [ ] Select AI difficulty per AI player
- [ ] Assign player colors

**Step 2: Extended Testing** (1 day)
- [ ] Test 3-player game
- [ ] Test 6-player game
- [ ] Test 10-player game (performance check)
- [ ] Verify turn order correct with many players
- [ ] Test economy scaling (enough room on terrain)

**Step 3: Visual Improvements** (1 day)
- [ ] Color-code players distinctly (10 colors)
- [ ] Show all players in turn order HUD
- [ ] Highlight current player clearly
- [ ] Ensure tanks don't overlap on spawn

**Acceptance Criteria**:
- ✅ 3-10 players fully playable
- ✅ All players have distinct colors
- ✅ Turn order clear and functional
- ✅ No performance issues with 10 players

---

### 2.4 - Teams Mode 🟡 MEDIUM (Week 3)

**Effort**: 1 week
**GDD Reference**: Section 3.3 (Teams Mode)

#### Implementation Tasks

**Step 1: Team Assignment** (2 days)
- [ ] Create TeamManager.gd script
- [ ] Assign players to 2-4 teams
- [ ] Team color system (all team members same color)
- [ ] Team victory condition (last team with surviving tanks)

**Step 2: Team Gameplay** (2 days)
- [ ] Implement friendly fire toggle (on/off)
- [ ] Shared team scoring
- [ ] Team communication indicators
- [ ] AI team coordination (optional)

**Step 3: Team UI** (2 days)
- [ ] Team scoreboard (team HP, kills, members)
- [ ] Visual team indicators (colored borders)
- [ ] Team victory screen

**Step 4: Testing** (1 day)
- [ ] Test 2 teams (2v2, 3v3)
- [ ] Test 4 teams (8 players total)
- [ ] Verify friendly fire works correctly
- [ ] Test team victory logic

**Acceptance Criteria**:
- ✅ 2-4 teams supported
- ✅ Friendly fire configurable
- ✅ Team victory condition works
- ✅ Teams visually distinct

---

### 2.5 - Main Menu System 🟡 MEDIUM (Week 4)

**Effort**: 1 week
**GDD Reference**: Section 4.1 (Main Menu)

#### Implementation Tasks

**Step 1: Main Menu Scene** (2 days)
- [ ] Create MainMenu.tscn scene
- [ ] Menu options:
  - New Game (Classic)
  - Tournament
  - Teams
  - Settings
  - Credits
  - Exit
- [ ] Button navigation (keyboard/mouse)
- [ ] Background (terrain preview animation)

**Step 2: Game Setup Flow** (2 days)
- [ ] Player count selection (2-10)
- [ ] Player configuration (human/AI, difficulty)
- [ ] Terrain theme selection
- [ ] Game mode selection
- [ ] Start game button

**Step 3: Settings Menu** (2 days)
- [ ] Audio volume controls
- [ ] Graphics settings (fullscreen, resolution)
- [ ] Controls configuration
- [ ] Game settings (starting money, tank HP, wind)

**Step 4: Polish** (1 day)
- [ ] Menu transitions
- [ ] Sound effects on hover/click
- [ ] Visual consistency

**Acceptance Criteria**:
- ✅ Main menu navigable and functional
- ✅ All game modes accessible
- ✅ Settings persist between sessions
- ✅ Clean visual design

---

### 2.6 - Audio System 🟡 MEDIUM (Week 5)

**Effort**: 1 week
**GDD Reference**: Section 6 (Audio Design)

#### Implementation Tasks

**Step 1: Sound Effects** (3 days)
- [ ] Weapon firing sounds (per weapon type)
- [ ] Explosion sounds (scale with damage)
- [ ] Terrain impact sounds
- [ ] UI sounds (click, purchase, error)
- [ ] Tank movement sounds
- [ ] Shield impact sounds

**Step 2: Background Music** (2 days)
- [ ] Main menu theme (upbeat, strategic)
- [ ] In-game music (subtle, non-intrusive)
- [ ] Victory fanfare
- [ ] Round transition music

**Step 3: Audio Integration** (2 days)
- [ ] Create AudioManager.gd singleton
- [ ] Volume controls (master, music, SFX)
- [ ] Audio ducking (lower music during explosions)
- [ ] Spatial audio for explosions (stereo positioning)

**Note**: Consider using royalty-free libraries:
- OpenGameArt.org
- Freesound.org
- Incompetech.com (Kevin MacLeod)

**Acceptance Criteria**:
- ✅ All major actions have sound effects
- ✅ Background music plays appropriately
- ✅ Volume controls functional
- ✅ No audio glitches or clipping

---

### 2.7 - Advanced Physics 🔵 LOW (Week 6 - Optional)

**Effort**: 1 week
**GDD Reference**: Section 2.1.2 (Physics System)

#### Implementation Tasks

**Step 1: Terrain Collapse** (3 days)
- [ ] Detect unsupported terrain (floating)
- [ ] Apply physics to detached segments
- [ ] Animate terrain falling
- [ ] Update collision after collapse
- [ ] Performance optimization

**Step 2: Tank Sliding** (2 days)
- [ ] Calculate slope angle under tank
- [ ] Apply sliding force on steep slopes (>30°)
- [ ] Stop sliding at flat terrain
- [ ] Damage if slide into obstacle

**Step 3: Improved Wind** (1 day)
- [ ] Variable wind per turn (not just per round)
- [ ] Wind gust system (sudden changes)
- [ ] Visual wind indicator (particles)

**Step 4: Gravity Customization** (1 day)
- [ ] Expose gravity as game setting
- [ ] Per-terrain gravity modifiers
- [ ] Test extreme gravity values

**Acceptance Criteria**:
- ✅ Terrain collapses realistically
- ✅ Tanks slide on steep slopes
- ✅ Wind system more dynamic
- ✅ No performance degradation

---

## Development Schedule

### Week 1: Terrain Variety 🟢
- **Days 1-2**: Theme selection UI
- **Days 3-4**: Enhance theme functions
- **Day 5**: Physics integration
- **Days 6-7**: Visual enhancements and testing

### Week 2: Tournament Mode + Multiplayer Polish 🟢
- **Days 1-2**: Tournament scoring system
- **Days 3-4**: Multi-round structure
- **Days 5-6**: Tournament UI
- **Day 7**: Multiplayer testing (3-10 players)

### Week 3: Teams Mode 🟡
- **Days 1-2**: Team assignment system
- **Days 3-4**: Team gameplay mechanics
- **Days 5-6**: Team UI
- **Day 7**: Testing and refinement

### Week 4: Main Menu System 🟡
- **Days 1-2**: Main menu scene
- **Days 3-4**: Game setup flow
- **Days 5-6**: Settings menu
- **Day 7**: Polish and transitions

### Week 5: Audio System 🟡
- **Days 1-3**: Sound effects
- **Days 4-5**: Background music
- **Days 6-7**: Audio integration

### Week 6 (Optional): Advanced Physics 🔵
- **Days 1-3**: Terrain collapse
- **Days 4-5**: Tank sliding
- **Days 6-7**: Wind/gravity improvements

---

## Testing Strategy

### Automated Testing
- **Tournament Scoring**: Unit tests for point calculations
- **Team Victory**: Test all team elimination scenarios
- **Multiplayer**: Automated playtest with 10 AI players

### Manual Testing
- **Terrain Themes**: Visual verification of all 5 themes
- **Game Modes**: Full playthrough of each mode
- **Audio**: Listen to all SFX and music
- **Physics**: Terrain collapse edge cases

### Performance Testing
- **10-Player Game**: Maintain 60 FPS
- **Terrain Collapse**: No frame drops
- **Audio**: No memory leaks from sound loading

---

## Success Metrics (Phase 2 Completion)

**Feature Completeness**:
- [ ] 5 terrain themes playable
- [ ] Tournament mode functional
- [ ] Teams mode functional
- [ ] 3-10 players fully supported
- [ ] Main menu system complete
- [ ] Audio system implemented
- [ ] (Optional) Advanced physics working

**Quality Metrics**:
- [ ] No critical bugs
- [ ] 60 FPS maintained (all modes)
- [ ] All game modes tested end-to-end
- [ ] Audio balanced and polished

**Player Experience**:
- [ ] Terrain variety adds visual interest
- [ ] Tournament mode increases replayability
- [ ] Teams mode adds strategic depth
- [ ] Audio enhances game feel

---

## Phase 2 → Phase 3 Transition

**Phase 3 Focus**: Polish & Testing
- Balance tuning (all weapons, all modes)
- Bug fixing (comprehensive QA)
- Performance optimization
- Closed beta testing (10-20 testers)
- Final polish pass

**Estimated Phase 3 Duration**: 2-3 weeks

---

## Technical Notes

### Dependencies
- Phase 2 builds on Phase 1 (95% complete)
- Terrain themes require Main.gd integration
- Tournament/Teams require GameManager.gd extensions
- Audio requires asset sourcing (royalty-free)

### Code Organization
- `scripts/TournamentManager.gd` - Tournament scoring/rounds
- `scripts/TeamManager.gd` - Team assignment/victory
- `scripts/AudioManager.gd` - Sound/music management
- `scripts/MainMenu.gd` - Menu navigation
- `scenes/MainMenu.tscn` - Main menu UI

### Performance Considerations
- Terrain themes: No additional overhead
- 10 players: Test CPU usage of AI calculations
- Audio: Stream music, cache SFX
- Terrain collapse: Optimize physics calculations

---

**Document Status**: READY FOR IMPLEMENTATION
**Next Action**: Begin 2.1 - Terrain Variety (Week 1)

Generated with [Claude Code](https://claude.com/claude-code)
via [Happy](https://happy.engineering)
