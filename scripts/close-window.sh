#!/bin/bash
# Close window with fallback
# Tries Quickshell IPC first, falls back to native Niri close-window

if qs -c ii ipc call closeConfirm trigger 2>/dev/null; then
    exit 0
fi

# Fallback: Quickshell not running, use native Niri
niri msg action close-window
