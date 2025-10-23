#!/bin/bash

echo "🔍 VIZOS QUICK SYSTEM CHECK"
echo "==========================="

echo -e "\n🖥️  Hardware:"
echo "CPU: $(grep -m 1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)"
echo "Cores: $(nproc)"
echo "RAM: $(free -h | awk '/^Mem:/{print $2}')"
echo "GPU: $(lspci | grep -i vga | cut -d: -f3 | head -1 | xargs)"

echo -e "\n📦 Dependencies:"
for dep in "vulkan" "x11"; do
    if pkg-config --exists $dep 2>/dev/null; then
        echo "✓ $dep: Available"
    else
        echo "✗ $dep: Not found"
    fi
done

echo -e "\n🚀 Components:"
for component in "window_manager_test" "input_dispatch_test" "vulkan_compositor_test" "vizos_desktop"; do
    if [ -f "./build/$component" ]; then
        echo "✓ $component: Built"
    else
        echo "✗ $component: Missing"
    fi
done

echo -e "\n✅ Quick check completed"
