#!/bin/bash
# Fix for audio crackling under heavy load
# This script sets the PipeWire quantum to 2048 to prevent underruns during gaming
mkdir -p ~/.config/pipewire/pipewire.conf.d
echo "context.properties = { default.clock.min-quantum = 1024, default.clock.max-quantum = 4096, default.clock.quantum = 2048 }" > ~/.config/pipewire/pipewire.conf.d/99-gaming.conf
echo "Applied audio quantum fix (2048). Restart pipewire or reboot to apply full effect."
