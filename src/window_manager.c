#include "window_manager.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* ────────────────────────────────────────────────
   Window Manager Implementation (V-Comp SSC)
   ──────────────────────────────────────────────── */

WindowManager* window_manager_create(void) {
    WindowManager* wm = calloc(1, sizeof(WindowManager));
    if (!wm) return NULL;
    wm->windows = NULL;
    wm->focused_window = NULL;
    wm->next_window_id = 1;
    wm->window_count = 0;
    return wm;
}

Window* window_create(WindowManager* wm, const char* title,
                      int x, int y, int width, int height,
                      uint32_t bg_color) {
    Window* window = calloc(1, sizeof(Window));
    if (!window) return NULL;

    window->id = wm->next_window_id++;
    strncpy(window->title, title, sizeof(window->title) - 1);
    window->x = x;
    window->y = y;
    window->width = width;
    window->height = height;
    window->bg_color = bg_color;
    window->z_order = wm->window_count++;
    window->focused = false;
    window->visible = true;
    window->next = wm->windows;
    window->prev = NULL;
    if (wm->windows)
        wm->windows->prev = window;
    wm->windows = window;

    printf("[window_manager] Created window '%s' (id=%d)\n",
           window->title, window->id);
    return window;
}

void window_bring_to_front(WindowManager* wm, Window* window) {
    if (!wm || !window || wm->windows == window) return;

    /* detach */
    if (window->prev) window->prev->next = window->next;
    if (window->next) window->next->prev = window->prev;

    /* re-insert at head */
    if (wm->windows) wm->windows->prev = window;
    window->next = wm->windows;
    window->prev = NULL;
    wm->windows = window;

    /* re-assign z-order */
    int z = 0;
    for (Window* c = wm->windows; c; c = c->next)
        c->z_order = z++;
}

void window_focus(WindowManager* wm, Window* window) {
    if (!wm || !window) return;
    if (wm->focused_window)
        wm->focused_window->focused = false;
    wm->focused_window = window;
    window->focused = true;
}

Window* window_at_position(WindowManager* wm, int x, int y) {
    for (Window* current = wm->windows; current; current = current->next) {
        if (current->visible &&
            x >= current->x && x < current->x + current->width &&
            y >= current->y && y < current->y + current->height)
            return current;
    }
    return NULL;
}

void window_destroy(WindowManager* wm, Window* window) {
    if (!wm || !window) return;
    if (window->prev) window->prev->next = window->next;
    if (window->next) window->next->prev = window->prev;
    if (wm->windows == window) wm->windows = window->next;
    if (wm->focused_window == window) wm->focused_window = NULL;
    free(window);
    wm->window_count--;
}

void window_manager_destroy(WindowManager* wm) {
    Window* current = wm->windows;
    while (current) {
        Window* next = current->next;
        free(current);
        current = next;
    }
    free(wm);
}
