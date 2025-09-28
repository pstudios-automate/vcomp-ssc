/*
 * VizOS - High-performance desktop environment
 * Copyright (c) 2025 Your Name
 *
 * This file is part of VizOS desktop environment
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <vulkan/vulkan.h>
#include "window_manager.h"

// =======================================================
// === WINDOW STRUCTURES =================================
// =======================================================

struct Window {
    uint32_t id;
    char title[64];
    
    // Geometry
    int32_t x, y;
    uint32_t width, height;
    int32_t z_order;
    
    // Visual state
    bool visible;
    bool focused;
    uint32_t bg_color;
    
    // Vulkan resources (would be textures/surfaces in real implementation)
    VkImage surface_image;
    VkImageView surface_view;
    
    struct Window* next;
    struct Window* prev;
};

struct WindowManager {
    Window* windows;
    Window* focused_window;
    uint32_t next_window_id;
    uint32_t window_count;
};

// =======================================================
// === WINDOW MANAGEMENT FUNCTIONS =======================
// =======================================================

WindowManager* window_manager_create() {
    WindowManager* wm = calloc(1, sizeof(WindowManager));
    if (!wm) return NULL;
    
    wm->next_window_id = 1;
    wm->window_count = 0;
    wm->focused_window = NULL;
    wm->windows = NULL;
    
    printf("Window manager created\n");
    return wm;
}

Window* window_create(WindowManager* wm, const char* title, int32_t x, int32_t y, 
                     uint32_t width, uint32_t height, uint32_t bg_color) {
    Window* window = calloc(1, sizeof(Window));
    if (!window) return NULL;
    
    window->id = wm->next_window_id++;
    strncpy(window->title, title, sizeof(window->title) - 1);
    window->x = x;
    window->y = y;
    window->width = width;
    window->height = height;
    window->z_order = wm->window_count; // New windows on top
    window->visible = true;
    window->focused = false;
    window->bg_color = bg_color;
    
    // Add to window list (front for easy access to top window)
    window->next = wm->windows;
    if (wm->windows) {
        wm->windows->prev = window;
    }
    wm->windows = window;
    wm->window_count++;
    
    printf("Created window: %s (ID: %u, %dx%d at %d,%d)\n", 
           title, window->id, width, height, x, y);
    
    return window;
}

void window_bring_to_front(WindowManager* wm, Window* window) {
    if (!window || wm->windows == window) return;
    
    // Remove from current position
    if (window->prev) window->prev->next = window->next;
    if (window->next) window->next->prev = window->prev;
    
    // Add to front
    window->next = wm->windows;
    window->prev = NULL;
    if (wm->windows) wm->windows->prev = window;
    wm->windows = window;
    
    // Update z-order for all windows
    Window* current = wm->windows;
    int32_t z = 0;
    while (current) {
        current->z_order = z++;
        current = current->next;
    }
    
    printf("Brought window '%s' to front\n", window->title);
}

void window_focus(WindowManager* wm, Window* window) {
    if (wm->focused_window) {
        wm->focused_window->focused = false;
    }
    
    wm->focused_window = window;
    if (window) {
        window->focused = true;
        window_bring_to_front(wm, window);
        printf("Focused window: %s\n", window->title);
    }
}

Window* window_at_position(WindowManager* wm, int32_t x, int32_t y) {
    // Check from top to bottom (front to back in z-order)
    Window* current = wm->windows;
    while (current) {
        if (current->visible &&
            x >= current->x && x < current->x + (int32_t)current->width &&
            y >= current->y && y < current->y + (int32_t)current->height) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void window_destroy(WindowManager* wm, Window* window) {
    if (!window) return;
    
    // Remove from list
    if (window->prev) window->prev->next = window->next;
    if (window->next) window->next->prev = window->prev;
    
    if (wm->windows == window) {
        wm->windows = window->next;
    }
    
    if (wm->focused_window == window) {
        wm->focused_window = NULL;
    }
    
    wm->window_count--;
    free(window);
    printf("Destroyed window\n");
}

void window_manager_destroy(WindowManager* wm) {
    if (!wm) return;
    
    Window* current = wm->windows;
    while (current) {
        Window* next = current->next;
        free(current);
        current = next;
    }
    
    free(wm);
    printf("Window manager destroyed\n");
}
