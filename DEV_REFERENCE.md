# Resonant Strike - Developer Reference

## Quick Reference

### File Locations
```
scripts/player/player_controller.gd      # Wing Chun combat system
scripts/enemies/enemy_base.gd            # Cinematic AI with telegraphed attacks  
scripts/managers/combat_manager.gd       # Enhanced with visual materials
scenes/main.tscn                         # Complete main scene
```

### Key Classes and Enums
```gdscript
enum WingChunStance { BONG_SAU, TAN_SAU, WU_SAU, CHI_SAU }
enum WingChunTechnique { CHAIN_PUNCH, TAN_DA, LAP_SAU, PAK_SAU }
enum EnemyState { KNEELING, STANDING, TELEGRAPHING, ATTACKING, DEFEATED }
```

## Development Checklist

### Core Systems Status
- [x] Wing Chun stance system (W/A/S/D) with traditional techniques (I/J/K/L)
- [x] First-person perspective with immersive camera
- [x] Energy wave creation and visualization 
- [x] Enhanced materials with metallic properties and rim lighting
- [x] Cinematic lighting with shadows and glow post-processing
- [x] Enemy AI with telegraphed attacks and energy wave responses
- [x] Close-quarters combat positioning
- [x] Visual enhancement system with emission effects

### Pending Art Assets
- [ ] Low poly player arms & hands (200-400 triangles per arm)
- [ ] Rigged low poly enemy character (500-1500 triangles)
- [ ] Enemy animations (kneeling, standing, combat, defeat)
- [ ] Ip Man dojo environment (traditional Chinese architecture)
- [ ] Arena mat with marked kneeling positions

### Testing Priorities
- [ ] Wing Chun authenticity validation
- [ ] Energy wave performance optimization
- [ ] Enhanced material rendering stability
- [ ] Arena system enemy positioning
- [ ] Combat resolution accuracy

## Common Code Patterns

### Enhanced Material Creation
```gdscript
func create_enhanced_material(base_color: Color) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    material.albedo_color = base_color
    material.metallic = 0.3
    material.roughness = 0.2
    material.emission_enabled = true
    material.emission = base_color * 2.0
    material.rim_enabled = true
    material.rim_power = 2.0
    return material
```

### Energy Wave Spawning
```gdscript
func create_energy_wave(technique: WingChunTechnique, stance: WingChunStance):
    var wave = preload("res://scenes/effects/energy_wave.tscn").instantiate()
    var color = get_stance_color(stance)
    var direction = get_technique_direction(technique)
    var material = create_enhanced_material(color)
    wave.setup(color, direction, material)
    get_tree().current_scene.add_child(wave)
```

### Signal Connections
```gdscript
signal stance_changed(new_stance: WingChunStance)
signal technique_performed(technique: WingChunTechnique)
signal energy_wave_created(wave_data: Dictionary)
```

## Performance Guidelines

### Material Optimization
- Reuse StandardMaterial3D instances for similar effects
- Pool enhanced materials to reduce runtime allocation
- Limit simultaneous energy waves to 10 maximum
- Use material caching for frequently used colors

### Visual Effects Limits
- Rim lighting: Maximum 2.0 power to prevent oversaturation
- Emission multiplier: 2.0x maximum for energy visibility
- Metallic property: 0.3 value for optimal visual appeal
- Roughness: 0.2 for smooth energy flow appearance

### Scene Management
- Keep enemy count below 8 for arena system
- Use LOD for distant visual effects
- Implement object pooling for energy waves
- Monitor draw calls in complex combat scenarios

## Architecture Notes

### Wing Chun System Design
- Stance selection precedes technique execution
- Energy wave properties derive from stance/technique combination
- Visual feedback provides immediate stance confirmation
- Combat resolution honors traditional Wing Chun principles

### Visual Enhancement Philosophy
- Enhanced materials serve gameplay clarity
- Rim lighting emphasizes energy wave boundaries
- Emission effects show internal power flow
- Metallic properties add premium visual quality

### Enemy AI Framework
- Telegraph system provides player reaction window
- Kneeling/standing states honor Ip Man 1 reference
- Sequential activation maintains single-combat focus
- Energy wave responses create visual combat dialogue

## Debugging Tools

### Console Commands
```gdscript
# Debug current stance
print("Stance: ", WingChunStance.keys()[current_stance])

# Check energy wave count
print("Active waves: ", get_tree().get_nodes_in_group("energy_waves").size())

# Validate materials
print("Material metallic: ", current_material.metallic)
```

### Visual Debug Helpers
```gdscript
func draw_stance_range():
    # Visualize Wing Chun effective range
    draw_circle_3d(global_position, 2.0, Color.GREEN)

func highlight_energy_paths():
    # Show energy wave trajectories
    for wave in active_waves:
        draw_line_3d(wave.start_pos, wave.target_pos, Color.BLUE)
```

## Extension Points

### New Wing Chun Techniques
1. Add enum value to WingChunTechnique
2. Implement technique logic in player_controller.gd
3. Define energy wave properties for technique
4. Add visual effects and audio cues
5. Update controls documentation

### Additional Enemy Types
1. Inherit from enemy_base.gd
2. Override attack patterns and telegraphs
3. Define unique energy wave responses
4. Implement defeat animations
5. Configure kneeling position behavior

### Arena Enhancements
1. Extend arena system in combat_manager.gd
2. Add environmental interaction points
3. Implement dynamic lighting changes
4. Create atmospheric particle effects
5. Design traditional Chinese architectural elements

## Version Control Guidelines

### Commit Patterns
- `feat: ` New features (Wing Chun techniques, visual effects)
- `fix: ` Bug fixes (combat resolution, material rendering)
- `docs: ` Documentation updates
- `perf: ` Performance improvements (material optimization)
- `refactor: ` Code restructuring without feature changes

### File Organization
- Keep scripts in appropriate subdirectories
- Use descriptive scene names with .tscn extension
- Store materials in assets/materials/ directory
- Maintain consistent naming conventions

## Quality Assurance

### Wing Chun Authenticity
- Verify stance colors match traditional associations
- Ensure technique directions follow Wing Chun principles
- Validate centerline theory implementation
- Confirm simultaneous attack/defense capability

### Visual Quality Standards
- Enhanced materials must have consistent metallic (0.3) properties
- Emission effects should be 2x base color intensity
- Rim lighting power should not exceed 2.0
- Energy waves must be clearly visible against environment

### Performance Benchmarks
- Maintain 60 FPS with full visual enhancement system
- Keep memory usage below 2GB for energy wave effects
- Ensure stable performance with 8 arena enemies
- Monitor material allocation and disposal

## Future Development

### Planned Features
- VR support for immersive Wing Chun training
- Multiplayer arena system for PvP combat
- Advanced Wing Chun forms and techniques
- Traditional Chinese music and sound design
- Master-level AI with unpredictable patterns

### Technical Improvements
- Shader-based energy wave rendering
- Advanced material system with custom shaders
- Procedural arena generation
- AI behavior trees for complex enemy patterns
- Physics-based Wing Chun collision detection

This developer reference provides the essential information needed to understand, maintain, and extend the Resonant Strike codebase while preserving the authentic Wing Chun philosophy and high-quality visual enhancement system that defines the game's character.