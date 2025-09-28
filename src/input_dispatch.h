/*
 * VizOS - High-performance desktop environment
 * Copyright (c) 2025 Your Name
 *
 * This file is part of VizOS desktop environment
 */

#ifndef INPUT_DISPATCH_H
#define INPUT_DISPATCH_H

#include <stdint.h>
#include <stdbool.h>

typedef struct InputDispatcher InputDispatcher;
typedef struct InputEvent InputEvent;

// Event types
typedef enum {
    MOUSE_MOVE,
    MOUSE_DOWN,
    MOUSE_UP,
    MOUSE_CLICK,
    KEY_DOWN,
    KEY_UP
} EventType;

// Input event structure
struct InputEvent {
    EventType type;
    int32_t x, y;
    int32_t button;
    uint32_t keycode;
    uint64_t timestamp;
};

// Input dispatch functions
InputDispatcher* input_dispatcher_create(const char* socket_path);
void input_dispatcher_set_callbacks(InputDispatcher* dispatcher, void* wm, 
                                   void (*callback)(void*, InputEvent*));
bool input_dispatcher_poll(InputDispatcher* dispatcher, int timeout_ms);
void simulate_mouse_event(InputDispatcher* dispatcher, InputEvent* event);
void input_dispatcher_destroy(InputDispatcher* dispatcher);

#endif
