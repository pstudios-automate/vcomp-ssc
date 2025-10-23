#!/usr/bin/env bash
set -euo pipefail

say() { printf "\033[1;32m[✔]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
die() { printf "\033[1;31m[✖]\033[0m %s\n" "$*" >&2; exit 1; }

mkdir -p build

say "=== Building V-Comp SSC ==="

# 1. Core components
say "1. Building core components..."
gcc -I. -Isrc -I./src -I./src -O2 -Wall -Wextra \
    src/vulkan_compositor.c \
    src/window_manager.c \
    src/input_dispatch.c \
    src/screenshot.c \
    -o build/vcomp_desktop \
    $(pkg-config --cflags --libs vulkan) -lpng16 -lz || die "Failed to build vcomp_desktop"

# 2. Test programs
say "2. Building test programs..."
gcc -I./src -O2 -Wall -Wextra tests/window_manager_test.c src/window_manager.c -o build/window_manager_test $(pkg-config --cflags --libs vulkan)
gcc -I./src -O2 -Wall -Wextra tests/input_dispatch_test.c src/input_dispatch.c -o build/input_dispatch_test $(pkg-config --cflags --libs vulkan)
gcc -I. -Isrc -I./src -I./src -O2 -Wall -Wextra tests/vulkan_compositor_test.c -o build/vulkan_compositor_test $(pkg-config --cflags --libs vulkan) || die "vulkan_compositor_test failed"

# 3. Screenshot utility (standalone)
say "3. Building screenshot tools..."
gcc -I. -Isrc -I./src -I./src -O2 -Wall -Wextra src/screenshot.c -o build/vcomp_screenshot -lpng16 -lz || die "screenshot tool failed"

say "=== Build complete ==="
echo "Run quick test  →  ./vcomp_quick_check.sh"
echo "Run benchmark   →  ./vcomp_benchmark.sh"
echo "Start compositor → ./build/vcomp_desktop"
