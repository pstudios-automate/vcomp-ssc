#ifndef WINDOW_MANAGER_H
#define WINDOW_MANAGER_H

#include <stdint.h>
#include <stdbool.h>

// Forward declarations
typedef struct Window Window;
typedef struct WindowManager WindowManager;

/**
 * Represents a single managed window in the compositor.
 * Implements a doubly-linked list structure.
 */
struct Window {
    int32_t   id;
    char      title[64];
    int32_t   x, y;
    int32_t   width, height;
    uint32_t  bg_color;
    bool      visible;
    int32_t   z_order;
    bool      focused;
    Window*   next;
    Window*   prev;
};

/**
 * Manages all windows and provides spatial/hit-test queries.
 */
struct WindowManager {
    Window*  windows;           // linked list head
    Window*  focused_window;    // currently focused window
    int      next_window_id;    // auto-incremented window IDs
    int      window_count;
};

/**
 * Allocates and initializes a new WindowManager.
 */
WindowManager* window_manager_create(void);

/**
 * Creates a new window and adds it to the manager.
 */
Window* window_create(WindowManager* wm,
                      const char* title,
                      int x, int y,
                      int width, int height,
                      uint32_t bg_color);

/**
 * Returns the topmost window at a given coordinate.
 */
Window* window_at_position(WindowManager* wm, int x, int y);

/**
 * Brings the specified window to the front of the z-order.
 */
void window_bring_to_front(WindowManager* wm, Window* window);

/**
 * Focuses a specific window (and unfocuses any currently focused one).
 */
void window_focus(WindowManager* wm, Window* window);

/**
 * Destroys a specific window and removes it from the manager.
 */
void window_destroy(WindowManager* wm, Window* window);

/**
 * Frees all windows and destroys the manager.
 */
void window_manager_destroy(WindowManager* wm);

#endif // WINDOW_MANAGER_H
