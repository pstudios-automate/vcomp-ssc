/*
 * VizOS - High-performance desktop environment
 * Copyright (c) 2025 Your Name
 *
 * This file is part of VizOS desktop environment
 */

#ifndef WINDOW_MANAGER_H
#define WINDOW_MANAGER_H

#include <stdint.h>
#include <stdbool.h>
#include <vulkan/vulkan.h>

typedef struct Window Window;
typedef struct WindowManager WindowManager;

// Window management functions
WindowManager* window_manager_create();
Window* window_create(WindowManager* wm, const char* title, int32_t x, int32_t y, 
                     uint32_t width, uint32_t height, uint32_t bg_color);
void window_bring_to_front(WindowManager* wm, Window* window);
void window_focus(WindowManager* wm, Window* window);
Window* window_at_position(WindowManager* wm, int32_t x, int32_t y);
void window_destroy(WindowManager* wm, Window* window);
void window_manager_destroy(WindowManager* wm);
// Add these function declarations
const char* window_get_title(Window* window);
unsigned int window_manager_get_window_count(WindowManager* wm);
Window* window_manager_get_focused_window(WindowManager* wm);

#endif
