## Resonant Strike — Copilot / AI Agent Instructions

Quick orientation
- Engine: Godot 4.5 (open `project.godot`). Use the Godot editor to import and run the project (F5 runs project, F6 runs current scene).
- Primary gameplay: 1v1 PvE Wing Chun duel. Player is stationary; enemies spawn and approach (see `scenes/main.tscn` and `scripts/managers/combat_manager.gd`).

What you should know to be productive
- Main systems and where to look:
  - Player & combat: `scripts/player/player_controller.gd` (stance enums, I/J/K/L attacks, signals: `stance_changed`, `attack_performed`).
  - Wing Chun system: `scripts/combat/wing_chun_combat_system.gd` (hitbox/hurtbox creation, frame data in `TECHNIQUE_FRAME_DATA`, stance properties `STANCE_PROPERTIES`).
  - Combat loop & spawning: `scripts/managers/combat_manager.gd` (enemy queue, spawn fallback to scripts when scenes missing, enemy wave progression logic).
  - Wave management: `scripts/waves/wave_system.gd` (wave lifecycle; docs and examples reference limiting active waves to 10).
  - Data resources: `resources/wave_types/wave_data.gd` and `resources/enemy_types/enemy_data.gd` define configurable wave/enemy parameters.
  - Scenes: `scenes/main.tscn`, `scenes/enemies/`, `scenes/player/` — CombatManager expects player to be in group `player`.

Key patterns and conventions (use these exactly)
- Stance/technique enums drive logic and visuals. When adding a technique: update enum in `player_controller.gd` and frame data in `wing_chun_combat_system.gd`, wire visuals in `scenes/effects` and emit `attack_performed`.
- Signals are the primary decoupling mechanism (e.g. `attack_performed` -> WaveSystem creates waves). Connect signals rather than calling into other nodes directly where possible.
- Visual material convention: enhanced materials use StandardMaterial3D with `metallic = 0.3`, `roughness = 0.2`, emission = `base_color * 2.0`, and rim lighting (`rim_power ~= 1.0 - 2.0`). See `DEV_REFERENCE.md` and `IMPLEMENTATION_GUIDE.md` snippets.
- Wave limits and pooling: limit active energy waves (docs recommend max 10) and reuse/cached materials via a pool (see `get_pooled_material` pattern in docs).
- Enemy instantiation: `CombatManager.spawn_next_enemy()` prefers `enemy_scenes` but falls back to script-based instantiation (`preload("res://scripts/enemies/*.gd").new()`). Be careful modifying spawn flow—both scene and script-based paths exist.

Developer workflows & useful commands
- Run the project locally: open Godot 4.5 and open `project.godot`, then F5.
- Run a single scene for quick tests: open the scene in Godot and press F6.
- Headless helper: `scripts/models/print_human_nodes.gd` is intended for headless inspection of the imported human scene (run with `godot --headless --script res://scripts/models/print_human_nodes.gd`). Useful to inspect skeleton bone names.

Common pitfalls and how to avoid them
- Missing nodes: many scripts expect specific node names (e.g. `$Camera3D/StanceIndicator`, `$Visual/LeftArm/LeftArmController`). When changing scene structure, update those `@onready` lookups.
- Material/visual regressions: follow the material parameters in docs. Avoid creating ephemeral StandardMaterial3D instances every frame—use pooling (see `get_pooled_material`).
- Spawning/scene vs script mismatch: `CombatManager` will try scenes then fall back to scripts—if you add or rename enemy scenes, update `enemy_scenes` on `CombatManager` or the spawn mapping.

Integration points to be careful with
- Group usage: players are found via `get_tree().get_first_node_in_group("player")`. Ensure the player scene is added to group `player`.
- Signals used by UI and wave system: `stance_changed`, `technique_performed` / `attack_performed`, and `energy_wave_created`. Altering signal names requires updating all connectors.
- Wave <> Combat interactions: `CombatManager.check_wave_collisions()` iterates `wave_system.active_waves` and uses proximity checks to call `wave_system.wave_hit_player()` / `wave_hit_enemy()`.

Small examples (copy/adapt)
- Add a new technique (minimal steps):
  1. Add enum entry in `scripts/player/player_controller.gd` and map key in `project.godot` input actions.
  2. Add TECHNIQUE_FRAME_DATA entry in `scripts/combat/wing_chun_combat_system.gd` (startup/active/recovery/damage/shape/position).
  3. Add visuals (energy wave prefab or `create_energy_wave` usage) and material via `get_pooled_material(color)`.
  4. Emit/connect `attack_performed` and validate interactions in `CombatManager`/`WaveSystem`.

Files worth reading first
- `README.md`, `SETUP_GUIDE.md`, `DEV_REFERENCE.md` (for high-level architecture and run steps)
- `scripts/player/player_controller.gd`, `scripts/combat/wing_chun_combat_system.gd`, `scripts/managers/combat_manager.gd` (core gameplay)
- `resources/wave_types/wave_data.gd`, `resources/enemy_types/enemy_data.gd` (config-driven values)

If you need to change anything else
- Preserve the signal names, enums, and the material parameters unless you intentionally change visuals or combat balance—these are relied on throughout the codebase.

Questions for the repo owner
- Do you want the AI agent to also open Godot, run scenes, or only edit scripts/MD files?
- Any coding style preferences beyond the current patterns (for example, prefer scenes over script instantiation for enemies)?

If anything here is incomplete or unclear, tell me which area to expand (spawning, waves, materials, or signals) and I will iterate.
