#!/bin/bash
# Close window - tries QS first (for confirm dialog), falls back to niri

if timeout 0.3 qs -c ii ipc call closeConfirm trigger 2>/dev/null; then
    exit 0
fi

# Fallback: Quickshell not running or hung
niri msg action close-window
