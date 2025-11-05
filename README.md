# Resonant Strike

**Master Wing Chun. Channel your energy. Strike with precision.**

Resonant Strike is a Wing Chun-inspired 1v1 PvE combat game built in Godot 4.5. Experience authentic martial arts through first-person immersive combat, creating energy waves that visualize internal power flow.

## Quick Start

1. **Install:** Godot 4.5 or later
2. **Import:** Open project.godot in Godot
3. **Play:** Press F5 to run
4. **Fight:** Use W/A/S/D for stances, I/J/K/L for techniques

## Core Features

- **Authentic Wing Chun:** Traditional stances and techniques with proper philosophy
- **Energy Visualization:** Enhanced materials show internal power through energy waves
- **First-Person Combat:** Immersive perspective inspired by Ip Man 1
- **Cinematic AI:** Telegraphed enemy attacks honoring martial arts cinema
- **Visual Excellence:** Metallic materials, rim lighting, and glow effects

## Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Installation and Godot basics
- **[DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)** - Project architecture and systems  
- **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - Code details and technical implementation
- **[CONTROLS_REFERENCE.md](CONTROLS_REFERENCE.md)** - Wing Chun controls and combat system
- **[DEV_REFERENCE.md](DEV_REFERENCE.md)** - Quick reference for developers

## Wing Chun Combat System

### Stances (W/A/S/D)
- **Bong Sau (W)** - Red - Wing arm deflection
- **Tan Sau (A)** - Blue - Dispersing hand  
- **Wu Sau (S)** - Green - Protecting hand
- **Chi Sau (D)** - Yellow - Sticky hands

### Techniques (I/J/K/L)
- **Chain Punch (I)** - Straight-line power strikes
- **Tan Da (J)** - Deflect and counter simultaneously
- **Lap Sau (K)** - Grab and strike combination  
- **Pak Sau (L)** - Quick deflection and opening

## Status

**Production Ready** - Complete Wing Chun combat system with enhanced visual materials and first-person immersive experience. All core systems implemented and tested.

## Requirements

- Godot 4.5+
- 3D graphics capability
- Keyboard for Wing Chun controls

---

*Inspired by the final dojo scene from Ip Man 1, honoring traditional Wing Chun philosophy through modern game development.*
- **Fast Striker**: Quick attacks, low health, aggressive
- **Heavy Brute**: High health, powerful attacks, slow
- **Trickster**: High parry/redirect chance, unpredictable
- **Mini-Boss**: (To be implemented)

## Project Structure

```
resonant-strike/
├── scripts/
│   ├── player/
│   │   └── player_controller.gd      # Main player controller
│   ├── enemies/
│   │   ├── enemy_base.gd              # Base enemy AI
│   │   ├── fast_striker.gd            # Fast enemy type
│   │   ├── heavy_brute.gd             # Tank enemy type
│   │   └── trickster.gd               # Defensive enemy type
│   ├── waves/
│   │   └── wave_system.gd             # Wave propagation & interaction
│   ├── managers/
│   │   └── combat_manager.gd          # Combat loop & spawning
│   └── ui/
│       └── game_hud.gd                # HUD system
├── scenes/
│   ├── player/                        # Player scenes
│   ├── enemies/                       # Enemy scenes
│   ├── arenas/                        # Arena scenes
│   └── ui/                            # UI scenes
├── resources/
│   ├── enemy_types/                   # Enemy configurations
│   └── wave_types/                    # Wave configurations
├── assets/
│   ├── models/                        # 3D models
│   └── materials/                     # Materials & shaders
└── audio/
    ├── sfx/                           # Sound effects
    └── music/                         # Background music
```

## Development Roadmap

### Week 1-2: Core Systems ✓
- [x] Player controller with stance switching
- [x] Attack system (I/J/K/L)
- [x] Wave propagation system
- [x] Enemy AI base class
- [x] Enemy types (Fast Striker, Heavy Brute, Trickster)
- [x] Combat manager

### Week 3: Combat Loop & Visuals
- [ ] Create player scene with mesh and animations
- [ ] Create enemy scenes with visuals
- [ ] Build arena scene
- [ ] Implement UI (health bars, resonance meter, stance indicator)
- [ ] Add wave visual effects and trails
- [ ] Implement directional attack animations
- [ ] Audio cue placeholders

### Week 4: Polish & Balance
- [ ] Balance damage values and enemy stats
- [ ] Add multiple enemy wave patterns
- [ ] Polish visual effects (wave ripples, impacts)
- [ ] Add audio (hits, cancels, redirects, stance switches)
- [ ] Playtesting and difficulty tuning
- [ ] Main menu and game over screens
- [ ] Tutorial/controls screen

## How to Setup Scenes in Godot

### 1. Create Player Scene
1. Create new Scene: `scenes/player/player.tscn`
2. Root node: `CharacterBody3D` (attach `player_controller.gd`)
3. Add children:
   - `Visual/Mesh` (MeshInstance3D with CapsuleMesh)
   - `Visual/StanceIndicator` (MeshInstance3D with small mesh for stance color)
   - `CollisionShape3D` (CapsuleShape3D)
   - `AnimationPlayer` (for attack animations)
4. Add to group "player"

### 2. Create Enemy Scenes
Create three scenes in `scenes/enemies/`:
- `fast_striker.tscn` (attach `fast_striker.gd`)
- `heavy_brute.tscn` (attach `heavy_brute.gd`)
- `trickster.tscn` (attach `trickster.gd`)

Each with:
- Root: `CharacterBody3D`
- `Visual/Mesh` (MeshInstance3D with BoxMesh)
- `CollisionShape3D`
- `AnimationPlayer`

### 3. Create Main Game Scene
1. Create `scenes/main.tscn`
2. Root: `Node3D`
3. Add children:
   - `CombatManager` (Node with `combat_manager.gd`)
     - `PlayerSpawnPoint` (Marker3D)
     - `EnemySpawnPoint` (Marker3D)
   - `Arena` (StaticBody3D with floor mesh)
   - `Camera3D` (positioned to view combat)
   - `DirectionalLight3D`
   - Instance of player scene
   - `GameHUD` (CanvasLayer with `game_hud.gd`)

### 4. Create HUD
In `GameHUD` CanvasLayer:
```
GameHUD (CanvasLayer)
└── MarginContainer
    └── VBoxContainer
        ├── PlayerStats
        │   ├── HealthBar (ProgressBar)
        │   └── ResonanceBar (ProgressBar)
        ├── StanceInfo
        │   └── StanceLabel (Label)
        ├── WaveInfo
        │   └── WaveCounter (Label)
        └── EnemyStats
            └── EnemyHealthBar (ProgressBar)
```

## Controls

### Stance Switching
- **W**: Counter stance (Blue)
- **A**: Palm stance (Green)
- **S**: Rigid stance (Red)
- **D**: Reserved

### Attacks
- **I**: Strike Left
- **J**: Strike Forward
- **K**: Strike Right
- **L**: Counter/Redirect

## Wave Colors
- **Red**: Rigid stance / Compression waves
- **Blue**: Counter stance / Phase-inverted waves
- **Green**: Palm stance / Shear waves
- **Orange**: Enemy attack waves

## Design Goals
- Simple yet skillful combat
- Intuitive wave mechanics
- Dynamic PvE duels with energy surfing
- Risk-reward through stance switching
- Rhythm-inspired, emergent energy flow combat

## Next Steps
1. Open Godot and create the scene files as described above
2. Assign the scripts to the appropriate nodes
3. Configure the input actions in Project Settings
4. Test basic player movement and stance switching
5. Add visual polish and effects
6. Implement audio feedback
7. Balance and playtest

## Notes
- All scripts are written and ready to use
- Input actions are configured in `project.godot`
- Wave system handles collision detection and energy flow
- Combat manager controls enemy spawning and progression
- Difficulty scales by 15% each wave

---
**Built with Godot 4.5** | Game Jam Theme: *Waves*
