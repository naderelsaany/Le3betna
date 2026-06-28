#!/bin/bash
echo "Installing Flutter..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b 3.24.5 --depth 1
fi
export PATH="$PATH:`pwd`/flutter/bin"
flutter config --no-analytics

echo "Flutter version:"
flutter --version

echo "Getting dependencies..."
flutter pub get

echo "Building Flutter Web (Verbose)..."
flutter build web --release -v
