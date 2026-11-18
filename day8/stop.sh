#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
# Stop the demo server if start.sh left it running; source files are kept.
if [ -f app.pid ]; then
    kill "$(cat app.pid)" 2>/dev/null || true
    rm -f app.pid
    echo "Stopped the TaskFlow demo server."
fi
echo "Cleanup complete."
