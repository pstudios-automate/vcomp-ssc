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
#include <unistd.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/un.h>

// =======================================================
// === INPUT EVENT SYSTEM ================================
// =======================================================

typedef enum {
    MOUSE_MOVE,
    MOUSE_DOWN,
    MOUSE_UP,
    MOUSE_CLICK,
    KEY_DOWN,
    KEY_UP
} EventType;

typedef struct InputEvent {
    EventType type;
    int32_t x, y;
    int32_t button;     // 0=left, 1=right, 2=middle
    uint32_t keycode;
    uint64_t timestamp;
} InputEvent;

typedef struct InputDispatcher {
    int socket_fd;
    bool running;
    void* window_manager;
    void (*event_callback)(void* wm, InputEvent* event);
} InputDispatcher;

// =======================================================
// === SOCKET PROTOCOL ===================================
// =======================================================

typedef enum {
    PROTOCOL_CREATE_WINDOW = 1,
    PROTOCOL_DESTROY_WINDOW,
    PROTOCOL_MOVE_WINDOW,
    PROTOCOL_RESIZE_WINDOW,
    PROTOCOL_SET_FOCUS
} ProtocolMessageType;

typedef struct ProtocolMessage {
    ProtocolMessageType type;
    uint32_t window_id;
    int32_t x, y;
    uint32_t width, height;
    char data[256];
} ProtocolMessage;

// =======================================================
// === INPUT DISPATCH FUNCTIONS ==========================
// =======================================================

InputDispatcher* input_dispatcher_create(const char* socket_path) {
    InputDispatcher* dispatcher = calloc(1, sizeof(InputDispatcher));
    if (!dispatcher) return NULL;
    
    // Create UNIX socket
    dispatcher->socket_fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (dispatcher->socket_fd < 0) {
        free(dispatcher);
        return NULL;
    }
    
    // Bind socket
    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path) - 1);
    
    unlink(socket_path); // Remove existing socket
    
    if (bind(dispatcher->socket_fd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        close(dispatcher->socket_fd);
        free(dispatcher);
        return NULL;
    }
    
    // Listen for connections
    if (listen(dispatcher->socket_fd, 5) < 0) {
        close(dispatcher->socket_fd);
        free(dispatcher);
        return NULL;
    }
    
    dispatcher->running = true;
    printf("Input dispatcher listening on %s\n", socket_path);
    return dispatcher;
}

void input_dispatcher_set_callbacks(InputDispatcher* dispatcher, void* wm, 
                                   void (*callback)(void*, InputEvent*)) {
    dispatcher->window_manager = wm;
    dispatcher->event_callback = callback;
}

bool input_dispatcher_poll(InputDispatcher* dispatcher, int timeout_ms) {
    if (!dispatcher->running) return false;
    
    fd_set read_fds;
    FD_ZERO(&read_fds);
    FD_SET(dispatcher->socket_fd, &read_fds);
    
    struct timeval timeout = {
        .tv_sec = timeout_ms / 1000,
        .tv_usec = (timeout_ms % 1000) * 1000
    };
    
    int result = select(dispatcher->socket_fd + 1, &read_fds, NULL, NULL, &timeout);
    if (result > 0 && FD_ISSET(dispatcher->socket_fd, &read_fds)) {
        // Accept connection and handle message
        int client_fd = accept(dispatcher->socket_fd, NULL, NULL);
        if (client_fd >= 0) {
            ProtocolMessage msg;
            ssize_t bytes = recv(client_fd, &msg, sizeof(msg), 0);
            if (bytes == sizeof(msg)) {
                printf("Protocol message received: type=%d, window=%u\n", 
                       msg.type, msg.window_id);
                // Handle protocol message
            }
            close(client_fd);
        }
        return true;
    }
    
    return false;
}

void simulate_mouse_event(InputDispatcher* dispatcher, InputEvent* event) {
    if (dispatcher->event_callback) {
        dispatcher->event_callback(dispatcher->window_manager, event);
    }
}

void input_dispatcher_destroy(InputDispatcher* dispatcher) {
    if (!dispatcher) return;
    
    dispatcher->running = false;
    if (dispatcher->socket_fd >= 0) {
        close(dispatcher->socket_fd);
    }
    free(dispatcher);
    printf("Input dispatcher destroyed\n");
}
