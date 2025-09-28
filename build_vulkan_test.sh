#!/bin/bash

echo "=== Building Vulkan Compositor Test ==="

# Check for Vulkan
if pkg-config --exists vulkan; then
    echo "✓ Vulkan found, building with hardware acceleration"
    VULKAN_FLAGS="`pkg-config --cflags --libs vulkan`"
    gcc -g -O0 -Wall -Wextra -o build/vulkan_compositor_test vulkan_compositor_test.c $VULKAN_FLAGS
else
    echo "⚠️  Vulkan not found, building basic test"
    gcc -g -O0 -Wall -Wextra -o build/vulkan_compositor_test vulkan_compositor_test.c -DNO_VULKAN
fi

echo "=== Test Built ==="
echo "Run: ./build/vulkan_compositor_test"
