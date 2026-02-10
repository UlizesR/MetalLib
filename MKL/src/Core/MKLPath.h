//
// MKLPath.h
// MetalLib - Executable-relative path resolution (no NSBundle)
//
// Resolves resource paths relative to the running executable so the library
// finds shaders, meshes, and textures regardless of current working directory.
// Uses _NSGetExecutablePath only; NSBundle is not used.
//

#ifndef MKLPath_h
#define MKLPath_h

#import <Foundation/Foundation.h>

/**
 * Resolve a resource path so it can be found regardless of CWD.
 * - Absolute paths (leading '/') are returned unchanged.
 * - Relative paths: first tried as (executable directory + path); if that file
 *   exists, that path is returned. Otherwise the original path is returned
 *   (CWD-relative fallback).
 * @param path UTF-8 path (e.g. "MKL/src/Graphics/Shaders/Shaders.metal" or "shadertoy.metal")
 * @return Resolved path, or nil if path is NULL
 */
NSString * _Nullable MKLResolveResourcePath(const char * _Nullable path);

#endif /* MKLPath_h */
