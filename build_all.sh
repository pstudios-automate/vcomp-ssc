#!/usr/bin/env bash
set -e

say() { printf "\033[1;32m[✔]\033[0m %s\n" "$*\n"; }

mkdir -p build

say "=== Building V-Comp SSC ==="

# 1. Core components
say "1. Building core components..."
gcc $(pkg-config --cflags --libs vulkan) \
    -I./src -O2 -Wall -Wextra \
    src/vulkan_compositor.c \
    src/window_manager.c \
    src/input_dispatch.c \
    src/screenshot.c \
    -o build/vcomp_desktop

# 2. Test programs
say "2. Building test programs..."
gcc $(pkg-config --cflags --libs vulkan) -I./src -O2 -Wall tests/window_manager_test.c -o build/window_manager_test
gcc $(pkg-config --cflags --libs vulkan) -I./src -O2 -Wall tests/input_dispatch_test.c  -o build/input_dispatch_test

# 3. Screenshot utility
say "3. Building screenshot tools..."
gcc $(pkg-config --cflags --libs libpng) -I./src -O2 -Wall src/screenshot.c -o build/vcomp_screenshot

say "=== Build complete ==="
echo "Run quick test  →  ./vcomp_quick_check.sh"
echo "Run benchmark  →  ./vcomp_benchmark.sh"
echo "Start compositor →  ./build/vcomp_desktop"
