//
// MKL.h
// MetalLib (MKL) - Main Header File
//
// A modern, high-performance graphics library for macOS using the Metal API.
// Provides a simple and intuitive API inspired by raylib for creating 3D graphics applications.
//
// Features:
// - Simple API inspired by raylib
// - High-performance Metal rendering
// - Window management and input handling
// - 3D primitives and mesh loading
// - Lighting and materials system
// - Texture mapping
// - Camera system
// - Performance monitoring
//
// Usage:
//   #include <MKL.h>
//
// Copyright (c) 2025 MetalLib Contributors
//

#ifndef MKL_H
#define MKL_H

// ============================================================================
// Core System
// ============================================================================
#include "Core/MKLConfig.h"         // Configuration constants
#include "Core/MKLDefaults.h"       // Default values
#include "Core/MKLCore.h"           // Core definitions and types
#include "Core/MKLError.h"          // Error handling
#include "Core/MKLTimer.h"          // Timing utilities

// ============================================================================
// Window and Input
// ============================================================================
#include "MKLWindow.h"              // Window management
#include "Input/KeyCodes.h"         // Keyboard key codes
#include "Input/Keyboard.h"         // Keyboard input
#include "Input/Mouse.h"            // Mouse input
#include "Input/MKLInput.h"         // Unified input system

// ============================================================================
// Math
// ============================================================================
#include "Math/MKLMath.h"           // Math utilities (vectors, matrices)

// ============================================================================
// Graphics - Core
// ============================================================================
#include "Graphics/MKLRenderer.h"      // Core rendering engine
#include "Graphics/MKLCommandBuffer.h" // Command buffer for batching (Phase 3)
#include "Graphics/MKLShader.h"        // Shader management

// ============================================================================
// Graphics - Objects and Geometry
// ============================================================================
#include "Graphics/Objects/MKLEntity.h"   // Camera and entities
#include "Graphics/Objects/MKLShapes.h"   // 2D/3D primitive shapes
#include "Graphics/Objects/MKLMesh.h"     // Mesh loading and rendering
#include "Graphics/Objects/MKLObjects.h"  // Object management

// ============================================================================
// Graphics - Visual Features
// ============================================================================
#include "Graphics/MKLTexture.h"        // Texture loading and management
#include "Graphics/MKLLight.h"          // Lighting system
#include "Graphics/MKLMaterial.h"       // Material properties
#include "Graphics/MKLText.h"           // Text rendering (in progress)
#include "Graphics/MKLRenderTarget.h"   // Render targets (in progress)
#include "Graphics/MKLAnimation.h"      // Animation system (in progress)

#endif // MKL_H

