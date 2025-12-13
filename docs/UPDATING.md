# Updating ii-niri

ii-niri respects your configurations. Updates never modify your personal settings without explicit consent.

## Quick Update

```bash
cd ~/path/to/ii-niri
git pull
./setup update
```

That's it. Your shell code is updated, your configs are untouched.

## What `update` Does

1. **Syncs QML code** to `~/.config/quickshell/ii/`
2. **Checks for new dependencies** and installs them
3. **Updates version file** for tracking
4. **Shows pending migrations** (if any)

What it does NOT do:
- Modify `~/.config/niri/config.kdl`
- Modify `~/.config/illogical-impulse/config.json`
- Change any of your personal settings

## Optional Migrations

New features sometimes need config changes. These are handled separately:

```bash
./setup migrate
```

This shows you:
- What each migration does
- Exactly what will change in your files
- Lets you choose which to apply

### Example Migration Flow

```
╔══════════════════════════════════════════════════════════════╗
║              ii-niri Configuration Migrations                ║
╚══════════════════════════════════════════════════════════════╝

Found 3 pending migration(s).

┌─ Migration: 004-audio-keybinds-ipc
│
│  Title: Audio Keybinds with OSD
│  File:  ~/.config/niri/config.kdl
│
│  Updates audio keybinds to use ii-niri IPC instead of wpctl.
│  This shows an on-screen display when changing volume.
│
│  Changes:
│    - XF86AudioRaiseVolume { spawn "wpctl" ... }
│    + XF86AudioRaiseVolume { spawn "qs" "-c" "ii" "ipc" "call" "audio" "volumeUp" }
│
└──────────────────────────────

Apply this migration? [y/n/v/a/q]
```

Options:
- `y` - Apply this migration
- `n` - Skip (won't ask again)
- `v` - View full diff
- `a` - Apply all remaining
- `q` - Quit (can continue later)

## Automatic Backups

Before any config change, ii-niri creates a backup:

```
~/.config/illogical-impulse/backups/
└── 2025-12-13-143052/
    ├── niri-config.kdl
    └── config.json
```

### Restore from Backup

```bash
# List available backups
./setup restore

# Restore specific backup
./setup restore 2025-12-13-143052
```

## Check Status

```bash
./setup status
```

Shows:
- Installed version
- Current version
- Migration status (applied/skipped/pending)
- Available backups

## Philosophy

1. **Your configs are yours** - We never modify them without asking
2. **Transparency** - You see exactly what will change before it happens
3. **Reversibility** - Automatic backups, easy restore
4. **Opt-in features** - New features via migrations are optional

## Troubleshooting

### Something broke after update

```bash
# Restore your configs
./setup restore

# Or manually restore from backup
cp ~/.config/illogical-impulse/backups/TIMESTAMP/niri-config.kdl ~/.config/niri/config.kdl
```

### Want to re-apply a skipped migration

Edit `~/.config/illogical-impulse/migrations.json` and remove the migration ID from the "skipped" array, then run `./setup migrate` again.

### Force fresh install behavior

```bash
./setup install --firstrun
```

This will backup existing configs and install fresh defaults.
