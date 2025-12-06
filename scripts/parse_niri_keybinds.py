#!/usr/bin/env python3
"""
Parse niri config.kdl to extract keybinds for ii cheatsheet.
Outputs JSON with categorized keybinds.
"""

import json
import os
import re
import sys
from pathlib import Path


def get_niri_config_path():
    """Get the path to niri config, checking XDG and fallback."""
    xdg_config = os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config"))
    return Path(xdg_config) / "niri" / "config.kdl"


def parse_keybind_line(line: str) -> dict | None:
    """
    Parse a single keybind line from niri config.
    Examples:
        Mod+Tab repeat=false { toggle-overview; }
        Alt+Tab { spawn "qs" "-c" "ii" "ipc" "call" "altSwitcher" "next"; }
        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" ... }
    """
    line = line.strip()
    if not line or line.startswith("//"):
        return None
    
    # Match: KEY_COMBO [options] { ACTION }
    # Key combo can be: Mod+Key, Alt+Shift+Key, XF86AudioSomething, Print, etc.
    match = re.match(
        r'^([A-Za-z0-9+_]+)\s*(?:[^{]*)?\{\s*([^}]+)\s*\}',
        line
    )
    if not match:
        return None
    
    key_combo = match.group(1)
    action_block = match.group(2).strip().rstrip(';')
    
    # Parse key combo into mods and key
    parts = key_combo.split('+')
    mods = []
    key = parts[-1]
    
    for part in parts[:-1]:
        if part in ('Mod', 'Super'):
            mods.append('Super')
        elif part == 'Alt':
            mods.append('Alt')
        elif part == 'Shift':
            mods.append('Shift')
        elif part == 'Ctrl':
            mods.append('Ctrl')
        else:
            mods.append(part)
    
    # Handle special keys
    if key.startswith('XF86'):
        # XF86AudioRaiseVolume -> Vol+
        key = key.replace('XF86Audio', '').replace('RaiseVolume', 'Vol+').replace('LowerVolume', 'Vol-').replace('Mute', 'Mute').replace('MicMute', 'MicMute')
        key = key.replace('XF86MonBrightness', 'Brightness').replace('Up', '+').replace('Down', '-')
    
    # Generate comment from action
    comment = generate_comment(action_block)
    
    return {
        'mods': mods,
        'key': key,
        'action': action_block,
        'comment': comment
    }


def generate_comment(action: str) -> str:
    """Generate a human-readable comment from the action."""
    action = action.strip()
    
    # Direct niri actions
    action_map = {
        'toggle-overview': 'Niri Overview',
        'quit': 'Quit Niri',
        'toggle-keyboard-shortcuts-inhibit': 'Toggle shortcuts inhibit',
        'close-window': 'Close window',
        'maximize-column': 'Maximize column',
        'fullscreen-window': 'Fullscreen',
        'toggle-window-floating': 'Toggle floating',
        'focus-column-left': 'Focus left',
        'focus-column-right': 'Focus right',
        'focus-window-up': 'Focus up',
        'focus-window-down': 'Focus down',
        'move-column-left': 'Move left',
        'move-column-right': 'Move right',
        'move-window-up': 'Move up',
        'move-window-down': 'Move down',
        'screenshot': 'Screenshot',
        'screenshot-screen': 'Screenshot screen',
        'screenshot-window': 'Screenshot window',
    }
    
    if action in action_map:
        return action_map[action]
    
    # Focus/move workspace
    ws_match = re.match(r'(focus-workspace|move-column-to-workspace)\s+(\d+)', action)
    if ws_match:
        ws_action = 'Focus' if 'focus' in ws_match.group(1) else 'Move to'
        return f'{ws_action} workspace {ws_match.group(2)}'
    
    # Spawn commands - extract meaningful info
    if action.startswith('spawn'):
        # ii IPC calls
        ipc_match = re.search(r'ipc.*call.*"(\w+)".*"(\w+)"', action)
        if ipc_match:
            target, func = ipc_match.groups()
            ipc_names = {
                ('altSwitcher', 'next'): 'Next window',
                ('altSwitcher', 'previous'): 'Previous window',
                ('overlay', 'toggle'): 'ii Overlay',
                ('overview', 'toggle'): 'ii Overview',
                ('clipboard', 'toggle'): 'Clipboard',
                ('lock', 'activate'): 'Lock Screen',
                ('region', 'screenshot'): 'Screenshot region',
                ('region', 'ocr'): 'OCR region',
                ('region', 'search'): 'Reverse image search',
                ('wallpaperSelector', 'toggle'): 'Wallpaper Selector',
                ('settings', 'open'): 'Settings',
                ('cheatsheet', 'toggle'): 'Cheatsheet',
                ('panelFamily', 'cycle'): 'Cycle panel style',
            }
            return ipc_names.get((target, func), f'{target} {func}')
        
        # Terminal
        if any(term in action for term in ['foot', 'kitty', 'alacritty', 'wezterm', 'ghostty']):
            return 'Terminal'
        
        # File manager
        if any(fm in action for fm in ['dolphin', 'nautilus', 'thunar', 'nemo', 'pcmanfm']):
            return 'File manager'
        
        # Volume
        if 'wpctl' in action:
            if 'set-volume' in action:
                if '+' in action:
                    return 'Volume up'
                elif '-' in action:
                    return 'Volume down'
            if 'set-mute' in action:
                return 'Mute toggle'
        
        # Brightness
        if 'brightnessctl' in action or 'light' in action:
            if '+' in action or 'inc' in action:
                return 'Brightness up'
            return 'Brightness down'
        
        # Close window script
        if 'close-window' in action:
            return 'Close window'
        
        # Generic spawn
        spawn_match = re.search(r'spawn\s+"([^"]+)"', action)
        if spawn_match:
            return spawn_match.group(1)
    
    return action[:40] + '...' if len(action) > 40 else action


def categorize_keybind(kb: dict) -> str:
    """Determine category for a keybind based on its action/comment."""
    comment = kb['comment'].lower()
    action = kb.get('action', '').lower()
    
    if any(x in comment for x in ['niri overview', 'quit', 'inhibit', 'power off']):
        return 'System'
    if any(x in comment for x in ['ii ', 'clipboard', 'lock', 'wallpaper', 'settings', 'cheatsheet', 'panel']):
        return 'ii Shell'
    if 'window' in comment and ('next' in comment or 'previous' in comment):
        return 'Window Switcher'
    if any(x in comment for x in ['screenshot', 'ocr', 'image search']):
        return 'Region Tools'
    if any(x in comment for x in ['terminal', 'file manager']) or any(x in action for x in ['foot', 'dolphin', 'nautilus']):
        return 'Applications'
    if any(x in comment for x in ['close', 'maximize', 'fullscreen', 'floating']):
        return 'Window Management'
    # Check action for close-window script
    if 'close-window' in action:
        return 'Window Management'
    if 'focus' in comment and 'workspace' not in comment:
        return 'Focus'
    if 'move' in comment and 'workspace' not in comment:
        return 'Move Windows'
    if 'workspace' in comment:
        return 'Workspaces'
    if any(x in comment for x in ['volume', 'mute', 'audio']):
        return 'Media'
    if 'brightness' in comment:
        return 'Brightness'
    
    return 'Other'


def find_binds_block(content: str) -> str | None:
    """Find the binds { } block handling nested braces."""
    # Find 'binds {' 
    match = re.search(r'\bbinds\s*\{', content)
    if not match:
        return None
    
    start = match.end()
    depth = 1
    i = start
    
    while i < len(content) and depth > 0:
        if content[i] == '{':
            depth += 1
        elif content[i] == '}':
            depth -= 1
        i += 1
    
    if depth == 0:
        return content[start:i-1]
    return None


def parse_niri_config(config_path: Path) -> dict:
    """Parse the niri config and extract keybinds."""
    if not config_path.exists():
        return {'error': f'Config not found: {config_path}', 'children': []}
    
    content = config_path.read_text()
    
    # Find the binds block
    binds_content = find_binds_block(content)
    if not binds_content:
        return {'error': 'No binds block found', 'children': []}
    
    # Parse each line
    keybinds_by_category = {}
    
    for line in binds_content.split('\n'):
        kb = parse_keybind_line(line)
        if kb:
            category = categorize_keybind(kb)
            if category not in keybinds_by_category:
                keybinds_by_category[category] = []
            keybinds_by_category[category].append({
                'mods': kb['mods'],
                'key': kb['key'],
                'comment': kb['comment']
            })
    
    # Convert to the format expected by CheatsheetKeybinds.qml
    category_order = [
        'System', 'ii Shell', 'Window Switcher', 'Region Tools',
        'Applications', 'Window Management', 'Focus', 'Move Windows',
        'Workspaces', 'Media', 'Brightness', 'Other'
    ]
    
    children = []
    for cat in category_order:
        if cat in keybinds_by_category and keybinds_by_category[cat]:
            children.append({
                'name': cat,
                'children': [{'keybinds': keybinds_by_category[cat]}]
            })
    
    return {'children': children, 'configPath': str(config_path)}


def main():
    config_path = get_niri_config_path()
    
    # Allow override via argument
    if len(sys.argv) > 1:
        config_path = Path(sys.argv[1])
    
    result = parse_niri_config(config_path)
    print(json.dumps(result))


if __name__ == '__main__':
    main()
