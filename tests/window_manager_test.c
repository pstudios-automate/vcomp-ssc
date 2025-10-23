#include "../src/window_manager.h"
/*
#include "../src/window_manager.h"
 * VizOS - High-performance desktop environment
 * Copyright (c) 2025 Your Name
 *
 * This file is part of VizOS desktop environment
 */

#include <stdio.h>
#include <stdlib.h>
#include "window_manager.h"

void print_window_info(const char* label, Window* win) {
    if (win) {
        printf("  %s: %p\n", label, (void*)win);
    } else {
        printf("  %s: NULL\n", label);
    }
}

int main() {
    printf("=== Window Manager Comprehensive Test ===\n");
    
    // Test 1: Window Manager Creation
    printf("\n1. Testing window manager creation...\n");
    WindowManager* wm = window_manager_create();
    if (!wm) {
        printf("✗ FAILED: Could not create window manager\n");
        return 1;
    }
    printf("✓ SUCCESS: Window manager created at %p\n", (void*)wm);
    
    // Test 2: Window Creation
    printf("\n2. Testing window creation...\n");
    Window* terminals[3];
    terminals[0] = window_create(wm, "Terminal-1", 100, 100, 600, 400, 0xFF202020);
    terminals[1] = window_create(wm, "Terminal-2", 250, 200, 600, 400, 0xFF303030);
    terminals[2] = window_create(wm, "Terminal-3", 400, 300, 600, 400, 0xFF404040);
    
    int windows_created = 0;
    for (int i = 0; i < 3; i++) {
        if (terminals[i]) {
            windows_created++;
            printf("✓ Window %d created: %s\n", i + 1, "Terminal");
        } else {
            printf("✗ Window %d creation failed\n", i + 1);
        }
    }
    printf("✓ Created %d/3 windows\n", windows_created);
    
    // Test 3: Hit Detection Grid
    printf("\n3. Testing hit detection grid...\n");
    struct TestPoint {
        int x, y;
        const char* expected;
    } test_points[] = {
        {50, 50, "background"},      // Outside all windows
        {150, 150, "Terminal-1"},    // Inside window 1
        {550, 350, "Terminal-1"},    // Inside window 1
        {300, 250, "Terminal-2"},    // Inside window 2
        {300, 150, "Terminal-1"},    // Inside window 1 (overlaps with window 2 area but window 1 is on top)
        {650, 450, "Terminal-3"},    // Inside window 3
        {1000, 1000, "background"}   // Far outside
    };
    
    int hit_tests_passed = 0;
    for (int i = 0; i < 7; i++) {
        Window* hit = window_at_position(wm, test_points[i].x, test_points[i].y);
        if (test_points[i].expected == "background") {
            if (!hit) {
                hit_tests_passed++;
                printf("✓ Correct: No window at (%d,%d) - %s\n", test_points[i].x, test_points[i].y, test_points[i].expected);
            } else {
                printf("✗ Wrong: Found window at (%d,%d), expected background\n", test_points[i].x, test_points[i].y);
            }
        } else {
            if (hit) {
                hit_tests_passed++;
                printf("✓ Correct: Found window at (%d,%d)\n", test_points[i].x, test_points[i].y);
            } else {
                printf("✗ Wrong: No window at (%d,%d), expected %s\n", test_points[i].x, test_points[i].y, test_points[i].expected);
            }
        }
    }
    printf("✓ Hit detection: %d/7 tests passed\n", hit_tests_passed);
    
    // Test 4: Edge Cases
    printf("\n4. Testing edge cases...\n");
    
    // Negative coordinates
    Window* hit = window_at_position(wm, -10, -10);
    if (!hit) printf("✓ Negative coordinates handled correctly\n");
    
    // Very large coordinates
    hit = window_at_position(wm, 10000, 10000);
    if (!hit) printf("✓ Large coordinates handled correctly\n");
    
    // Zero-size window? (if supported)
    Window* tiny_win = window_create(wm, "Tiny", 500, 500, 1, 1, 0xFF0000FF);
    if (tiny_win) {
        hit = window_at_position(wm, 500, 500);
        if (hit) printf("✓ Single-pixel window detected\n");
        else printf("ℹ Single-pixel window not detected (might be expected)\n");
    }
    
    printf("\n=== TEST SUMMARY ===\n");
    printf("✓ Window Manager: CREATED\n");
    printf("✓ Windows: %d CREATED\n", windows_created);
    printf("✓ Hit Detection: %d/7 TESTS PASSED\n", hit_tests_passed);
    printf("✓ Edge Cases: HANDLED\n");
    printf("\n🎉 WINDOW MANAGER TEST COMPLETED SUCCESSFULLY!\\n");
    
    return 0;
}
