# VizOS  
[![Build](https://img.shields.io/github/actions/workflow/status/pstudios-automate/vizos/ci.yml?branch=master)](https://github.com/pstudios-automate/vizos/actions)  
[![License: MIT](https://img.shields.io/github/license/pstudios-automate/vizos)](LICENSE)  
[![Stars](https://img.shields.io/github/stars/pstudios-automate/vizos?style=social)](https://github.com/pstudios-automate/vizos)  

⚡ **VizOS** is a high-performance, Vulkan-accelerated desktop environment.  
Designed for speed and efficiency: **~101ms startup, ~7.8ms window creation**.  

---

## ✨ Features
- **Vulkan Compositor** – hardware-accelerated rendering pipeline with fallback.  
- **Window Manager** – creation, hit-testing, and edge-case handling.  
- **Input Dispatch System** – event routing for mouse/keyboard devices.  
- **Benchmark Suite** – measure performance on real hardware.  
- **Screenshot Tool** – direct compositor framebuffer capture to `.ppm`/`.png`.  

---

## 📊 Benchmarks

| Test                  | Avg Time     |
|-----------------------|--------------|
| **Desktop Startup**   | 101 ms       |
| **Window Creation**   | 7.8 ms       |
| **Input Dispatch**    | 257 ms/event |
| **GPU Compositor**    | Stable at 4K, ~320 MB VRAM @ 4 layers |

> Benchmarks run on Intel Iris Xe (Mesa 25.2.3, Vulkan 1.4.318).  

---

## 🖥️ Screenshot
Example compositor output:  

![VizOS Compositor](docs/vizos_screenshot.png)  

---

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/pstudios-automate/vizos.git
cd vizos

# Build everything
./build_all.sh

# Run quick system check
./vizos_quick_check.sh

# Run full benchmark suite
./vizos_benchmark.sh

Eof
