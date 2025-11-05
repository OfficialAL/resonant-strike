# Resonant Strike - Developer Guide

## Project Overview

**Resonant Strike** is a Wing Chun-inspired 1v1 PvE combat game built in Godot 4.5. Players engage in close-quarters combat using authentic Wing Chun stances and techniques, creating energy waves inspired by Ip Man 1.

**Core Concept:** Master Wing Chun. Channel your energy. Strike with precision.

**Status:** Production Ready

## Architecture

### Key Systems
- Player Controller - Wing Chun stance system (W/A/S/D) with traditional techniques (I/J/K/L)
- Enemy AI - Cinematic combat with telegraphed attacks and energy wave responses
- Wave System - Visual energy wave propagation with enhanced materials
- Combat Manager - Close-quarters combat loop with enhanced enemy positioning
- Visual Enhancement System - Metallic materials, emission effects, glow post-processing
- Environment System - Sky background with enhanced lighting

## Wing Chun Combat System

### Stances (W/A/S/D)
| Key | Stance | Color | Description |
|-----|--------|-------|-------------|
| W | Bong Sau | Red | Wing arm deflection |
| A | Tan Sau | Blue | Dispersing hand |
| S | Wu Sau | Green | Protecting hand |
| D | Chi Sau | Yellow | Sticky hands |

### Techniques (I/J/K/L)
| Key | Technique | Description |
|-----|-----------|-------------|
| I | Chain Punch | Straight-line power strikes |
| J | Tan Da | Deflect and counter simultaneously |
| K | Lap Sau | Grab and strike combination |
| L | Pak Sau | Quick deflection and opening |

### Implemented Features
- First-person perspective with immersive camera
- Hand visualization spheres for left/right hands
- Color-coded stance indicator
- Energy wave creation and visualization
- Enhanced materials with metallic properties and rim lighting
- Cinematic lighting with shadows

## Combat Flow

1. Game Start
2. Player Assumes Wing Chun Stance
3. Enemy Telegraphs Attack
4. Player Chooses Wing Chun Technique
5. Energy Wave Creation
6. Combat Resolution based on Wing Chun principles
7. Continue or Victory

## File Structure

### Core Scripts
```
scripts/
├── player/
│   └── player_controller.gd      # Wing Chun combat system
├── enemies/
│   ├── enemy_base.gd             # Cinematic AI with telegraphed attacks
│   └── fast_striker.gd           # Enhanced enemy with Wing Chun techniques
├── managers/
│   └── combat_manager.gd         # Enhanced with visual materials
└── ui/
    └── game_hud.gd               # HUD system
```

### Scene Files
```
scenes/
├── main.tscn                     # Complete main scene
├── player/
│   └── player.tscn               # First-person Wing Chun setup
└── enemies/
    └── fast_striker.tscn         # Enhanced enemy with materials
```

## Visual Enhancement System

### Enhanced Materials
- Energy Wave Materials: Metallic properties (0.3), low roughness (0.2), 2x emission
- Rim Lighting Effects: Dramatic edge highlighting
- Enemy Materials: Glowing dark red appearance with emission
- Human Proportions: Enemy mesh sized as Vector3(0.8, 1.8, 0.6)

### Environment Enhancements
- Sky Background: ProceduralSkyMaterial
- Enhanced Lighting: DirectionalLight3D with shadows and 1.5x energy
- Glow Post-Processing: Intensity 0.8, strength 1.2, bloom 0.1
- Tone Mapping: Mode 2 with 1.1x exposure
- Ambient Lighting: Soft blue ambient with 0.3 energy

### Color System
- Red (Bong Sau): Power and deflection
- Blue (Tan Sau): Flow and dispersion
- Green (Wu Sau): Balance and protection
- Yellow (Chi Sau): Sensitivity and connection
- Dark Red (Enemy): Opposition and challenge

## Art Asset Requirements

### Low Poly Player Arms & Hands
**Current:** Simple sphere indicators
**Needed:** Professional first-person viewmodel arms
- Style: Low poly (200-400 triangles per arm)
- Components: Forearms + hands with proper finger positioning
- Texturing: Realistic skin tones with stylized aesthetic
- Rigging: Basic bone structure for Wing Chun hand positioning

### Rigged Low Poly Enemy Character
**Current:** Simple box mesh with enhanced materials
**Needed:** Full humanoid character with skeleton
- Poly Count: 500-1500 triangles
- Style: Intimidating but stylized martial artist
- Rigging: Full humanoid skeleton with IK chains
- Texturing: Traditional martial arts clothing

**Required Animations:**
- Kneeling Position: Respectful seiza position at arena edge
- Standing Transition: Smooth rise from kneel to combat stance
- Combat Ready Stance: Traditional martial arts ready position
- Attack Telegraphs: Wind-up motions for Wing Chun counters
- Impact Reactions: Response to player energy waves
- Defeat Animation: Return to kneeling or respectful bow

### Ip Man Dojo Environment
**Current:** Basic ground plane
**Needed:** Enclosed traditional Chinese dojo with arena mat
- Reference: Final dojo scene from Ip Man 1
- Size: 10x10 to 15x15 meters enclosed space
- Style: Traditional Chinese architecture, low poly optimized

**Environmental Elements:**
- Arena Mat: Central fighting surface with marked kneeling positions
- Wooden Floor: Traditional plank flooring around arena mat
- Wooden Pillars: 4-6 support pillars with traditional Chinese styling
- Paper Screens: Translucent room dividers with traditional patterns
- Wall Panels: Wooden wall sections with traditional joinery

## Design Principles

1. Authentic Wing Chun - Traditional stances and techniques with proper philosophy
2. Visual Clarity - Enhanced materials and lighting make energy waves clearly visible
3. Cinematic Experience - First-person perspective inspired by Ip Man 1
4. Energy Visualization - Waves show internal power flow through enhanced materials
5. Immersive Training - Close-quarters combat positioning for authentic Wing Chun range
6. Technical Excellence - Enhanced materials, rim lighting, and glow effects

## Current Status Summary

Resonant Strike is production ready with a complete Wing Chun combat system featuring authentic stances and techniques, first-person immersive combat experience, enhanced visual materials with metallic properties and rim lighting, complete environment setup with sky background and glow effects, close-quarters combat positioning inspired by Ip Man 1, and energy wave visualization showing internal power flow.

The game successfully captures the cinematic essence of Wing Chun combat with modern visual enhancements, creating an immersive training experience that honors traditional martial arts philosophy while leveraging cutting-edge game development techniques.