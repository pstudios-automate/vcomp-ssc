# VizOS Architecture

## Core Components

### Window Manager
- Spatial window management
- Hit detection and z-ordering  
- Focus management
- Window lifecycle

### Vulkan Compositor
- Hardware-accelerated rendering
- Layer-based compositing
- Resource management
- Frame synchronization

### Input Dispatcher
- Event-driven architecture
- Socket communication
- Callback system

## Performance Characteristics

- Startup: 101ms
- Window Creation: 7.8ms
- Frame Rendering: 95ms
- Event Processing: 258ms
