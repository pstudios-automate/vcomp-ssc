#!/bin/bash

echo "Installing VizOS..."

# Check dependencies
if ! pkg-config --exists vulkan; then
    echo "Vulkan not found. Please install Vulkan development packages."
    echo "Ubuntu: sudo apt install libvulkan-dev"
    echo "Arch: sudo pacman -S vulkan-icd-loader"
    echo "Fedora: sudo dnf install vulkan-devel"
    exit 1
fi

# Build VizOS
echo "Building VizOS..."
./build_all.sh

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 VizOS installed successfully!"
    echo ""
    echo "Quick start:"
    echo "  ./build/vizos_desktop        # Start desktop"
    echo "  ./vizos_benchmark.sh         # Run tests"
    echo "  ./build/screenshot           # Generate screenshot"
else
    echo "❌ Build failed"
    exit 1
fi
