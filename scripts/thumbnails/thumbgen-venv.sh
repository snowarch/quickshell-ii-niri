#!/usr/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${ILLOGICAL_IMPULSE_VIRTUAL_ENV:-}" ]]; then
    echo "[thumbgen-venv.sh] ILLOGICAL_IMPULSE_VIRTUAL_ENV is not set" >&2
    exit 127
fi

VENV_DIR="$(eval echo "$ILLOGICAL_IMPULSE_VIRTUAL_ENV")"
if [[ ! -f "$VENV_DIR/bin/activate" ]]; then
    echo "[thumbgen-venv.sh] venv activate not found: $VENV_DIR/bin/activate" >&2
    exit 127
fi

source "$VENV_DIR/bin/activate"
/usr/bin/python3 "$SCRIPT_DIR/thumbgen.py" "$@"
deactivate
