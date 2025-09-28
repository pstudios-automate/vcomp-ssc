/*
 * VizOS - High-performance desktop environment
 * Copyright (c) 2025 Your Name
 *
 * This file is part of VizOS desktop environment
 */

#ifndef VULKAN_COMPOSITOR_H
#define VULKAN_COMPOSITOR_H

#include <stdint.h>
#include <stdbool.h>
#include <vulkan/vulkan.h>

typedef struct VulkanCompositor VulkanCompositor;

// Compositor functions
VulkanCompositor* compositor_create(VkDevice device, VkPhysicalDevice physical_device, 
                                   uint32_t max_layers);
uint32_t compositor_add_layer(VulkanCompositor* compositor, uint32_t width, uint32_t height);
void compositor_set_layer_opacity(VulkanCompositor* compositor, uint32_t layer_id, float opacity);
void compositor_render_layers(VulkanCompositor* compositor, VkCommandBuffer cmd_buffer, 
                             VkFramebuffer framebuffer, uint32_t width, uint32_t height);
void compositor_destroy(VulkanCompositor* compositor);
// Add these function declarations  
unsigned int vulkan_compositor_get_layer_count(VulkanCompositor* compositor);
unsigned int vulkan_compositor_get_max_layers(VulkanCompositor* compositor);

#endif
