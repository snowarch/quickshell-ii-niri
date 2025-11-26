# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Commands

### Installation & Setup
This project uses a custom Bash-based setup script found in the root.
- **Full Install**: `./setup install` (installs dependencies, system setups, and config files).
- **Install Dependencies Only**: `./setup install-deps`
- **Update Configs**: `./setup update` (syncs QML and config files to `~/.config/quickshell/ii`).

### Running & Debugging
The shell is run via the `qs` (Quickshell) CLI.
- **View Logs**: `qs log -c ii` (Essential for debugging runtime QML errors).
- **Reload Config**: `niri msg action reload-config` (if integrated with Niri) or restart the `spawn-at-startup` process.
- **Manual Start**: `qs -c ii` (if testing outside of compositor autostart, though typically run by Niri).

### IPC Control
Inter-process communication is handled via the `qs` CLI calling into the running `ii` instance.
- **Syntax**: `qs -c ii ipc call <target> <function>`
- **Examples**:
    - Toggle Overlay: `qs -c ii ipc call overlay toggle`
    - Screenshot: `qs -c ii ipc call region screenshot`
    - See `docs/IPC.md` for all available targets.

## Architecture

### Overview
**illogical-impulse (ii)** is a desktop shell built on [Quickshell](https://git.outfoxxed.me/outfoxxed/quickshell) using Qt/QML. It is designed primarily for the **Niri** Wayland compositor, with legacy/partial support for Hyprland.

### Key Components
- **Entry Point**: `shell.qml` is the main entry point. It uses `LazyLoader` to load enabled modules based on configuration.
- **State Management**:
    - `GlobalStates.qml`: A Singleton holding runtime state (window open/closed status, lock state, etc.).
    - `modules/common/Config.qml`: A Singleton that adapts the JSON configuration (`config.json`) into QML properties. It handles read/write operations.
- **Theming System**:
    - `modules/common/Appearance.qml`: Centralized theming singleton.
    - **Material 3**: Implements Material You dynamic coloring derived from the wallpaper using `matugen` (external tool) or internal logic.
    - **Fonts/Rounding**: centralized in `Appearance.qml`.
- **Service Layer**:
    - `services/`: Contains non-UI logic and singletons.
    - `CompositorService.qml`: Abstracts compositor-specific logic (Niri vs Hyprland), handling window listing, workspace management, and monitor power control.

### Directory Structure
- `modules/`: Contains UI components organized by feature (e.g., `bar`, `overlay`, `sidebarRight`).
    - `common/`: Shared widgets and utilities used across modules.
- `services/`: QML Singletons for backend logic (Battery, Network, Audio, AI).
- `defaults/`: Default configuration files and assets.
- `dots/`: Dotfiles (configs) that are copied to the user's home directory by the setup script.
- `scripts/`: Helper scripts (Python/Bash) for tasks like color generation, AI processing, and system integration.

### Configuration
Configuration is stored in `~/.config/quickshell/ii/config.json`. The `Config` singleton in QML provides a typed interface to this JSON data.
- **Editing Config**: Users can edit the JSON manually or use the built-in Settings app (`settings.qml`).
- **Auto-Reload**: `Config.qml` watches the file for changes and updates properties dynamically.

## Development Guidelines

1.  **Niri Focus**: Prioritize Niri compatibility (`CompositorService` checks `isNiri`).
2.  **Singleton Usage**: Use `GlobalStates` for UI state and `Config` for persistent user preferences. Do not introduce ad-hoc state management if it fits these existing patterns.
3.  **Theming**: Always use `Appearance.colors.*`, `Appearance.rounding.*`, and `Appearance.font.*` instead of hardcoded values to maintain consistency with the generated theme.
4.  **IPC**: If adding a new controllable feature, expose it via `IpcHandler` in `GlobalStates.qml` or the relevant module, and document it.
