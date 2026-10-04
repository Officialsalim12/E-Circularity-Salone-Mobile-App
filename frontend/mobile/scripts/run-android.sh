#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! flutter devices | grep -q 'android'; then
  echo "No Android device or emulator. Starting Medium Phone API 36.1…"
  flutter emulators --launch Medium_Phone_API_36.1
  echo "Waiting for emulator…"
  for _ in $(seq 1 60); do
    if flutter devices | grep -q 'android'; then
      break
    fi
    sleep 2
  done
fi

flutter run -d android
