/*
 * VizOS - High-performance desktop environment
 * Copyright (c) 2025 Your Name
 *
 * This file is part of VizOS desktop environment
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "input_dispatch.h"

void test_event_callback(void* wm, InputEvent* event) {
    (void)wm;
    if (event) {
        const char* types[] = {"MOUSE_MOVE", "MOUSE_DOWN", "MOUSE_UP", "MOUSE_CLICK", "KEY_DOWN", "KEY_UP"};
        printf("Event: %s at (%d,%d)\n", 
               event->type < 6 ? types[event->type] : "UNKNOWN", 
               event->x, event->y);
    }
}

int main() {
    printf("=== Input Dispatch Test ===\n");
    
    InputDispatcher* dispatcher = input_dispatcher_create("/tmp/vizos_test");
    if (!dispatcher) {
        printf("✗ Failed to create input dispatcher\n");
        return 1;
    }
    printf("✓ Input dispatcher created\n");
    
    input_dispatcher_set_callbacks(dispatcher, NULL, test_event_callback);
    printf("✓ Callbacks set\n");
    
    // Test with simulated events
    InputEvent test_events[] = {
        {MOUSE_MOVE, 100, 150, 0, 0, 0},
        {MOUSE_CLICK, 100, 150, 1, 0, 0}
    };
    
    for (int i = 0; i < 2; i++) {
        simulate_mouse_event(dispatcher, &test_events[i]);
        usleep(100000);
    }
    
    input_dispatcher_poll(dispatcher, 50);
    input_dispatcher_destroy(dispatcher);
    
    printf("✓ Input test completed!\n");
    return 0;
}
