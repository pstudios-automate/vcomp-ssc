#!/bin/bash

echo "=== Building VizOS ==="

mkdir -p build

# Check for Vulkan
if pkg-config --exists vulkan; then
    echo "Vulkan found, building with hardware acceleration"
    VULKAN_FLAGS="\`pkg-config --cflags --libs vulkan\`"
else
    echo "Vulkan not found. Using software fallback."
    VULKAN_FLAGS=""
fi

CFLAGS="-g -O0 -Wall -Wextra"

echo "1. Building core components..."
gcc $CFLAGS -c src/window_manager.c -o build/window_manager.o $VULKAN_FLAGS
gcc $CFLAGS -c src/input_dispatch.c -o build/input_dispatch.o
gcc $CFLAGS -c src/vulkan_compositor.c -o build/vulkan_compositor.o $VULKAN_FLAGS

echo "2. Building test programs..."
gcc $CFLAGS -o build/window_manager_test tests/window_manager_test.c build/window_manager.o -lm
gcc $CFLAGS -o build/input_dispatch_test tests/input_dispatch_test.c build/input_dispatch.o
gcc $CFLAGS -o build/vulkan_compositor_test tests/vulkan_compositor_test.c build/vulkan_compositor.o $VULKAN_FLAGS

echo "3. Building integrated desktop..."
gcc $CFLAGS -c src/vizos_desktop.c -o build/vizos_desktop.o $VULKAN_FLAGS
gcc $CFLAGS -o build/vizos_desktop \
    build/window_manager.o \
    build/input_dispatch.o \
    build/vulkan_compositor.o \
    build/vizos_desktop.o \
    $VULKAN_FLAGS -lm

echo "4. Building screenshot tools..."
gcc $CFLAGS -o build/screenshot src/screenshot.c -lpng

echo ""
echo "=== Build Complete ==="
echo "Test: ./vizos_benchmark.sh"
echo "Run: ./build/vizos_desktop"
