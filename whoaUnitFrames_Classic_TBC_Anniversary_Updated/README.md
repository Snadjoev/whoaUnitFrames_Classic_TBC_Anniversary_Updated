# whoaUnitFrames Classic (TBC Anniversary Edition)

A refined and enhanced version of whoaUnitFrames for WoW TBC Classic Anniversary (Interface 20505).

## Features

- **Custom Unit Frame Textures**: Light and dark theme support for player, target, focus, and party frames
- **Custom Party Frames**: Fully featured party frames with drag-to-reposition, scaling, and whoa styling
- **Class Colors**: Optional class-colored health bars with blue shaman support
- **Reaction Colors**: Bright, customizable reaction colors for NPCs
- **Name Backgrounds**: Optional BigRedButton-style backgrounds for unit names
- **Status Bar Customization**: Custom textures and fonts with heal prediction support
- **Enhanced Status Text**: Abbreviated numbers (1.5K, 2.3M) for health/mana values, percentage display
- **Role Indicators**: Show tank/healer/DPS icons on player, target, focus, and party frames
- **Focus Frame Support**: Full focus frame styling
- **Dead/Offline Status**: Custom "Dead", "Ghost", and "Offline" text with gray health bars
- **Settings Panel**: Modern in-game UI for all options (`/whoa` or `/wtf`)

## Requirements

- **WoW TBC Classic Anniversary** (Interface 20505)
- Uses modern WoW client with full Retail API support
- No external dependencies required

## Installation

1. Download the addon
2. Extract the `whoaUnitFrames_Classic` folder into your `World of Warcraft\_classic_\Interface\AddOns\` directory
3. Restart WoW or `/reload`

## Usage

- Type `/whoa` or `/wtf` to open the settings panel
- Use checkboxes to enable/disable features
- Most settings require a `/reload` (or `/rl`) to take full effect

### Party Frames
- **Enable/Disable**: Toggle "whoa party frames" in settings
- **Drag to Move**: Right-click and drag any party frame to move all frames together
- **Lock/Unlock**: Use the "Lock party frames" checkbox to prevent accidental moves
- **Reset Position**: Click "Reset party positions" and `/reload` to restore default layout
- **Scale**: Use the slider to adjust party frame size (0.5x to 1.5x)
- **Transparency**: Adjust party frame visibility when out of combat (0-100%)
- **Flat Background**: Toggle flat background style for party frames
- **Show Percentages**: Display health/mana as percentages

## Settings

### Main Options
- **Player class colors**: Color health bars by player class
- **Blue shamans**: Use blue color for shamans instead of pink
- **Target reaction colors**: Enable custom reaction colors for NPCs
- **Bright reaction colors**: Use brighter colors for better visibility
- **Enable dark frames**: Switch to dark-themed frame textures
- **Show name background**: Display red button background behind unit names
- **Show player name**: Toggle player name visibility
- **Enable whoa textures**: Use whoa custom status bar textures

### Party Frame Options
- **Enable whoa party frames**: Use custom party frames (requires `/reload`)
- **Lock party frames**: Prevent party frames from being moved
- **Show flat background**: Use flat background style for party frames
- **Show percentages**: Display health/mana as percentages
- **Party frame scale**: Adjust size of party frames (slider)
- **Party frame alpha**: Set transparency when out of combat (slider)
- **Reset party positions**: Clear saved positions and restore defaults

## Commands

- `/whoa` or `/wtf` - Open settings panel
- `/partypos` - Display current saved party frame positions
- `/resetparty` - Clear all saved party frame positions

## Credits

- **Original Author**: whoarrior
- **Classic Port**: delabarra
- **TBC Anniversary Update**: IAmDetonate
- **Enhanced Edition**: Additional features and refinements
