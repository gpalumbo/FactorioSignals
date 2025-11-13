# Mission Control Mod - Asset Specification Document

## Asset Format Requirements

### General Specifications
- **Format:** PNG with transparency (RGBA)
- **Resolution:** Standard (SD) and High Definition (HD) versions
  - SD: Base resolution
  - HD: 2x resolution with `hr_version` in code
- **Color Depth:** 32-bit (8-bit per channel RGBA)
- **Sprite Sheets:** For animations, arranged horizontally or in grid
- **Shadow Rendering:** Separate shadow layer with 50% opacity black
- **Mipmaps:** 4 levels for icons (64x64, 32x32, 16x16, 8x8)

### File Naming Convention
```
entity-name__state__resolution.png

Examples:
mission-control-building__base__hr.png
mission-control-building__shadow.png
receiver-combinator__working__hr.png
logistics-combinator__remnants.png
```

## 1. Mission Control Building (5x5 entity)

### Required Assets

#### Base Entity Sprites
| Asset | Size (SD) | Size (HD) | Frames | Description |
|-------|-----------|-----------|---------|-------------|
| `base` | 320x320px | 640x640px | 1 | Static base structure |
| `base_shadow` | 320x320px | 640x640px | 1 | Shadow layer |
| `antenna_animation` | 320x320px | 640x640px | 60 | Rotating dish animation |
| `antenna_shadow` | 320x320px | 640x640px | 60 | Animated shadow |

#### State Variations
| State | Sprite Layers | Description |
|-------|---------------|-------------|
| `idle` | base + antenna(static) | No power/not connected |
| `working` | base + antenna_animation | Powered and transmitting |
| `no_power` | base + dark overlay | Connected but unpowered |

#### LED Indicators
| Asset | Size | Frames | Colors |
|-------|------|---------|--------|
| `led_strip` | 32x8px | 4 | Off, Green (connected), Yellow (transmitting), Red (error) |
| `led_positions` | - | - | 4 LEDs on front face of building |

#### Additional Elements
| Asset | Size | Description |
|-------|------|-------------|
| `circuit_connectors` | 16x16px each | 4 connection points sprite overlay |
| `remnants` | 320x320px | Destroyed state (rubble + broken dish) |
| `explosion` | 320x320px | 8 frames destruction animation |

### Working Visualization
```
Frame composition:
Layer 1: Base building (static)
Layer 2: Shadow (static)  
Layer 3: Antenna (rotating 1 RPM)
Layer 4: LED strip (color based on state)
Layer 5: Transmission effect (optional, pulse when sending)
```

## 2. Receiver Combinator (1x1 entity)

### Required Assets

#### Base Entity Sprites
| Asset | Size (SD) | Size (HD) | Frames | Description |
|-------|-----------|-----------|---------|-------------|
| `base` | 64x64px | 128x128px | 1 | Combinator box with dish |
| `base_shadow` | 64x64px | 128x128px | 1 | Shadow layer |
| `dish_receiving` | 32x32px | 64x64px | 32 | Dish scanning animation |
| `display` | 16x12px | 32x24px | 1 | LCD display area |

#### State Variations
| State | Visual Indicator | Description |
|-------|------------------|-------------|
| `connected` | Green LCD + dish moving | Orbiting configured planet |
| `searching` | Yellow LCD + dish scanning | In orbit but not configured |
| `transit` | Red LCD + dish folded | Traveling between planets |
| `idle` | Dark LCD + dish static | No power or not in space |

#### Direction Variants
| Direction | Rotation | Connector Position |
|-----------|----------|-------------------|
| North | 0° | Bottom side |
| East | 90° | Left side |
| South | 180° | Top side |
| West | 270° | Right side |

#### Additional Elements
| Asset | Size | Description |
|-------|------|-------------|
| `circuit_connectors` | 8x8px each | 4 wire connection points |
| `remnants` | 64x64px | Destroyed state |
| `quality_glow` | 64x64px | Overlay for quality tiers |

## 3. Logistics Combinator (2x1 entity)

### Required Assets

#### Base Entity Sprites
| Asset | Size (SD) | Size (HD) | Frames | Description |
|-------|-----------|-----------|---------|-------------|
| `base` | 128x64px | 256x128px | 1 | Combinator with logistics icon |
| `base_shadow` | 128x64px | 256x128px | 1 | Shadow layer |
| `led_display` | 96x16px | 192x32px | 1 | LED indicator area |

#### LED States
| State | Color | Pattern | Meaning |
|-------|-------|---------|---------|
| `inactive` | Dark gray | All off | No rules configured |
| `ready` | Green | Solid | Rules configured, none active |
| `active_1-3` | Green | 1-3 LEDs lit | Number of active rules |
| `active_4+` | Yellow | 4 LEDs lit | 4+ active rules |
| `error` | Red | Blinking | Invalid configuration |

#### Direction Variants
| Direction | Rotation | Input/Output Layout |
|-----------|----------|-------------------|
| North | 0° | Input bottom, Output top |
| East | 90° | Input left, Output right |
| South | 180° | Input top, Output bottom |
| West | 270° | Input right, Output left |

#### Additional Elements
| Asset | Size | Description |
|-------|------|-------------|
| `activity_pulse` | 128x64px | 8 frame pulse effect when triggering |
| `remnants` | 128x64px | Destroyed state |
| `quality_glow` | 128x64px | Overlay for quality tiers |

## 4. Icons and GUI Elements

### Item Icons
| Icon | Sizes | Description |
|------|-------|-------------|
| `mission-control-building` | 64x64, 32x32 | Inventory/crafting icon |
| `receiver-combinator` | 64x64, 32x32 | Inventory/crafting icon |
| `logistics-combinator` | 64x64, 32x32 | Inventory/crafting icon |

### Technology Icons
| Icon | Size | Description |
|------|------|-------------|
| `mission-control-tech` | 256x256 | Research screen icon |
| `logistics-circuit-control-tech` | 256x256 | Research screen icon |

### GUI Sprites
| Sprite | Size | Usage |
|--------|------|-------|
| `mc-connection-active` | 32x32 | Status indicator in GUI |
| `mc-connection-inactive` | 32x32 | Status indicator in GUI |
| `mc-transmission-icon` | 24x24 | Animation when sending |
| `surface-selector-checkbox` | 16x16 | Custom checkbox if needed |
| `logistic-group-injected` | 16x16 | Indicator for injected groups |

## 5. Effect Overlays (Optional Enhanced Visuals)

### Transmission Effects
| Effect | Size | Frames | Description |
|--------|------|---------|-------------|
| `signal_beam` | 128x512px | 30 | Vertical beam when transmitting |
| `signal_pulse_ground` | 256x256px | 20 | Radial pulse from MC |
| `signal_pulse_space` | 128x128px | 20 | Radial pulse from receiver |

### Connection Visualization
| Effect | Description |
|--------|-------------|
| `circuit_flow` | Animated dots along wires (optional) |
| `data_particles` | Small particle effects at connection points |

## 6. Quality Tier Variations

### Visual Distinctions by Quality
| Quality | Visual Modification |
|---------|-------------------|
| Normal | Base textures |
| Uncommon | +5% brightness, subtle green tint on metal |
| Rare | +10% brightness, blue accent lights |
| Epic | +15% brightness, purple accent lights + glow |
| Legendary | +20% brightness, orange glow + particle effects |

## 7. Color Palette Guidelines

### Primary Colors (match Factorio's style)
```
Metal Base: #3D4447 (dark gray)
Metal Highlight: #6B7376 (light gray)  
Rust/Weathering: #8B4513 (saddle brown)
Tech Blue: #00FFFF (circuit color)
Active Green: #00FF00 (working state)
Warning Yellow: #FFFF00 (transmission)
Error Red: #FF0000 (disconnected)
```

### Material Guidelines
- **Metal:** Weathered steel with rust spots
- **Screens:** LCD/LED style with slight glow
- **Antennas:** Shiny metal with less weathering
- **Wires:** Match vanilla red/green circuit wire colors

## 8. Animation Specifications

### Frame Rates
| Animation Type | FPS | Frame Count |
|---------------|-----|-------------|
| Antenna rotation | 60 | 60 (1 second loop) |
| LED blinking | 2 | 2 (on/off) |
| Dish scanning | 30 | 32 frames |
| Pulse effects | 30 | 20 frames |
| Destruction | 15 | 8 frames |

### Sprite Sheet Layout
```
For animations with >8 frames:
- Use grid layout (8xN)
- Read left-to-right, top-to-bottom
- Power of 2 dimensions preferred

Example for 32 frame dish animation:
Grid: 8x4 (32 frames)
Each frame: 32x32px (SD) or 64x64px (HD)
Total sheet: 256x128px (SD) or 512x256px (HD)

Example for 60 frame antenna animation:
Grid: 8x8 (64 frames, last 4 unused)
Each frame: 80x80px (SD) or 160x160px (HD)
Total sheet: 640x640px (SD) or 1280x1280px (HD)
```

## 9. File Structure
```
/
├── graphics/
│   ├── entity/
│   │   ├── mission-control/
│   │   │   ├── mission-control-base.png
│   │   │   ├── mission-control-base-hr.png
│   │   │   ├── mission-control-shadow.png
│   │   │   ├── mission-control-shadow-hr.png
│   │   │   ├── mission-control-antenna.png
│   │   │   ├── mission-control-antenna-hr.png
│   │   │   ├── mission-control-leds.png
│   │   │   └── mission-control-remnants.png
│   │   ├── receiver-combinator/
│   │   │   ├── receiver-combinator-base.png
│   │   │   ├── receiver-combinator-base-hr.png
│   │   │   ├── receiver-combinator-dish.png
│   │   │   ├── receiver-combinator-dish-hr.png
│   │   │   └── ...
│   │   └── logistics-combinator/
│   │       ├── logistics-combinator-base.png
│   │       ├── logistics-combinator-base-hr.png
│   │       └── ...
│   ├── icons/
│   │   ├── mission-control-building.png
│   │   ├── receiver-combinator.png
│   │   └── logistics-combinator.png
│   ├── technology/
│   │   ├── mission-control.png
│   │   └── logistics-circuit-control.png
│   └── gui/
│       └── ...
```

## 10. Asset Creation Checklist

### Per Entity Checklist
- [ ] Base sprite (normal + HR)
- [ ] Shadow sprite (normal + HR)
- [ ] All rotation variants (N/E/S/W)
- [ ] Working animation if applicable
- [ ] LED/display states
- [ ] Remnants (destroyed state)
- [ ] Item icon (mipmaps)
- [ ] Circuit connection point sprites
- [ ] Quality tier overlays (5 levels)

### Global Assets
- [ ] Technology icons (2)
- [ ] GUI status indicators
- [ ] Wire connection point markers
- [ ] Particle effects (optional)
- [ ] Transmission effects (optional)

## Notes for Artists

1. **Match Factorio's Art Style:**
   - Industrial/mechanical aesthetic
   - Weathered and used appearance
   - Consistent lighting from top-left
   - Subtle wear and rust details

2. **Antenna Design:**
   - Should look more advanced than vanilla radar
   - Include satellite dish element
   - Visible reinforced mounting for space communication

3. **Combinator Integration:**
   - Should visually fit with existing combinators
   - Use similar display styles and case design
   - Maintain consistent scale and proportions

4. **Performance Considerations:**
   - Keep sprite sheet dimensions to powers of 2
   - Minimize transparent pixels (crop tightly)
   - Use indexed color where possible for static sprites
   - Provide lower resolution versions for performance mode

5. **Accessibility:**
   - Ensure LED colors are distinguishable for colorblind users
   - Include shape or pattern differences not just color
   - Make connection points clearly visible

## Delivery Format
- Provide all assets in organized folders
- Include source files (PSD/ASE/KRITA)
- Document any special rendering settings
- Provide example JSON sprite definitions
