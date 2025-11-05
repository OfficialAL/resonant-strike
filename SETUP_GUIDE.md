# Resonant Strike - Setup Guide

## Prerequisites

**Required:**
- Godot 4.5 or later
- Computer with 3D graphics capability

**Optional but Recommended:**
- Git for version control
- Code editor with GDScript syntax highlighting
- VR headset for future immersive development

## Quick Start

1. Clone the repository
2. Open Godot 4.5
3. Import the project by selecting `project.godot`
4. Run the project (F5 or click Play button)

## Godot Setup

### First-Time Godot Installation
1. Download Godot 4.5 from official website
2. Extract to preferred directory
3. Run `godot.exe` to start the engine
4. Create desktop shortcut for quick access

### Project Import
1. Launch Godot
2. Click "Import" in project manager
3. Navigate to project folder and select `project.godot`
4. Click "Import & Edit"
5. Wait for initial import process

### Scene Management
The project uses a main scene architecture:
- `main.tscn` - Primary game scene
- `player.tscn` - Player character setup
- `enemy.tscn` - Enemy character template

## Node Structure

### Player Scene Structure
```
Player (CharacterBody3D)
└── Camera3D
    ├── StanceIndicator (MeshInstance3D)
    ├── LeftHand (MeshInstance3D)
    └── RightHand (MeshInstance3D)
```

### Main Scene Structure
```
Main (Node3D)
├── Player (CharacterBody3D)
├── Enemy (CharacterBody3D)
├── Environment (Node3D)
│   ├── Ground (StaticBody3D)
│   ├── Sky (Environment)
│   └── DirectionalLight3D
└── UI (CanvasLayer)
    └── HUD (Control)
```

## Essential Godot Concepts

### Nodes and Scenes
- **Node:** Basic building block with specific functionality
- **Scene:** Collection of nodes saved as reusable template
- **Scene Tree:** Hierarchical structure of all nodes

### 3D Nodes Used
- **CharacterBody3D:** Physics body for player/enemies
- **MeshInstance3D:** Visual 3D object representation
- **Camera3D:** Player viewpoint
- **StaticBody3D:** Non-moving physics objects
- **DirectionalLight3D:** Main lighting source

### GDScript Basics
```gdscript
# Variables
var player_health: int = 100
@export var damage: float = 25.0

# Functions
func _ready():
    print("Node is ready")

func _process(delta):
    # Called every frame
    pass
```

## Common Operations

### Adding New Scenes
1. Right-click in FileSystem dock
2. Select "New Scene"
3. Choose appropriate root node type
4. Save with descriptive name

### Connecting Signals
1. Select node in scene
2. Go to "Node" tab next to Inspector
3. Find desired signal
4. Click "Connect"
5. Choose target node and method

### Testing Changes
- **F5:** Run project
- **F6:** Run current scene
- **Ctrl+R:** Reload current scene

## Project-Specific Setup

### Wing Chun Combat Controls
Set up input map in Project Settings:
- W/A/S/D for stances
- I/J/K/L for techniques
- Mouse for camera look (if needed)

### Material Setup
Enhanced materials are pre-configured with:
- Metallic properties (0.3)
- Low roughness (0.2) 
- 2x emission for energy waves
- Rim lighting effects

### Environment Configuration
Pre-configured environment includes:
- Sky background with ProceduralSkyMaterial
- DirectionalLight3D with shadows and 1.5x energy
- Glow post-processing effects

## Development Workflow

### Making Changes
1. Open relevant scene file
2. Modify nodes or scripts as needed
3. Test with F6 (current scene) or F5 (full project)
4. Save changes with Ctrl+S

### Adding Features
1. Identify which scene needs modification
2. Add necessary nodes to scene tree
3. Attach scripts if custom behavior needed
4. Configure node properties
5. Test functionality

### Debugging
- Use `print()` statements for basic debugging
- Check Output panel for error messages
- Use debugger for complex issues

## Asset Management

### Importing 3D Models
1. Place model files in `assets/models/` folder
2. Godot auto-imports supported formats
3. Adjust import settings if needed
4. Use ResourcePreloader for complex assets

### Material System
Materials are stored in `assets/materials/` and include:
- Enhanced energy wave materials
- Enemy materials with glow effects
- Environment materials with proper lighting

## Troubleshooting

### Common Issues
- **Black screen:** Check camera positioning and lighting
- **No input response:** Verify input map configuration
- **Missing materials:** Check file paths and import settings
- **Performance issues:** Reduce visual effects or polygon count

### Performance Optimization
- Keep polygon counts reasonable
- Use LOD (Level of Detail) for distant objects
- Optimize texture sizes
- Profile with Godot's built-in profiler

## Next Steps

After setup completion:
1. Review DEVELOPER_GUIDE.md for system architecture
2. Check CONTROLS_REFERENCE.md for input mapping
3. Consult IMPLEMENTATION_GUIDE.md for code details
4. Use DEV_REFERENCE.md for advanced development topics