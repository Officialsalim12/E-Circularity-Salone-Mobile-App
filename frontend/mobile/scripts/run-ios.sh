#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! flutter devices | grep -q 'ios'; then
  echo "No iOS simulator or device. Starting iOS Simulator…"
  flutter emulators --launch apple_ios_simulator
  echo "Waiting for simulator…"
  for _ in $(seq 1 45); do
    if flutter devices | grep -qi 'simulator'; then
      break
    fi
    sleep 2
  done
fi

flutter run -d ios
