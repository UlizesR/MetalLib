/**
 * Guli example: sinewave ripple effect (SDF from center).
 * Loads shaders from files. Uses Metal or OpenGL depending on backend.
 *
 * Build: cd build && cmake .. && make guli_test
 * Run: ./bin/guli_test  (shaders copied to build/bin/shaders/)
 */
 #include <guli/guli.h>
 #include <stdio.h>
 #include <string.h>
 
 static const char* kWindowTitle = "Guli Ripple - SDF sinewave (ESC to close)";
 
 static int is_valid_loc(int loc) { return loc >= 0; }
 
 int main(void)
 {
     GuliShader* shader = NULL;
     int exit_code = 1;
 
     if (GuliInit(800, 600, kWindowTitle) != GULI_ERROR_SUCCESS)
         return 1;
 
 #if defined(GULI_BACKEND_METAL)
    // Expect shader next to executable: build/bin/shaders/ripple.metal
    const char* metalPath = "/Users/ulirodriguez/CodeProjects/MetalLib-1/shaders/ripple.metal";
    shader = GuliShaderLoadFromFile(metalPath, NULL);
 #elif defined(GULI_BACKEND_OPENGL)
    const char* vertPath = "/Users/ulirodriguez/CodeProjects/MetalLib-1/shaders/ripple.vert.glsl";
    const char* fragPath = "/Users/ulirodriguez/CodeProjects/MetalLib-1/shaders/ripple.frag.glsl";
    shader = GuliShaderLoadFromFile(vertPath, fragPath);
 #else
 #   error "Define one backend: GULI_BACKEND_METAL or GULI_BACKEND_OPENGL"
 #endif
 
     if (!shader || !GuliShaderIsValid(shader))
     {
         fprintf(stderr, "Failed to load ripple shader (run from build/bin/)\n");
         goto cleanup;
     }
 
     // Consider making these tweakable via keys later; keep const for now.
     const float frequency = 25.0f;
     const float speed     = 4.0f;
 
     const int loc_time   = GuliShaderGetLocation(shader, "time");
     const int loc_freq   = GuliShaderGetLocation(shader, "frequency");
     const int loc_speed  = GuliShaderGetLocation(shader, "speed");
     const int loc_aspect = GuliShaderGetLocation(shader, "aspect");
 
     // Cache framebuffer size to avoid querying each frame.
     int fb_w = 0, fb_h = 0;
     float aspect = 1.0f;
     GuliGetFramebufferSize(&fb_w, &fb_h);
     if (fb_h > 0) aspect = (float)fb_w / (float)fb_h;
 
     while (!GuliWindowShouldClose())
     {
         GuliPollEvents();
         if (GuliGetKey(GULI_KEY_ESCAPE) == GULI_PRESS)
             GuliSetWindowShouldClose(1);
 
         // Only recompute aspect if size changed.
         int new_w = 0, new_h = 0;
         GuliGetFramebufferSize(&new_w, &new_h);
         if (new_w != fb_w || new_h != fb_h)
         {
             fb_w = new_w;
             fb_h = new_h;
             aspect = (fb_h > 0) ? (float)fb_w / (float)fb_h : 1.0f;
         }
 
         const float t = (float)GuliGetTime();
 
         GuliBeginDraw();
 
         // If your Metal backend uses a fullscreen draw clear, this color is still valid.
         GuliClearColor((GULI_COLOR){0.05f, 0.05f, 0.10f, 1.0f});
 
         GuliShaderUse(shader);
 
         // Be tolerant of shaders that omit some uniforms.
         if (is_valid_loc(loc_time))   GuliShaderSetFloat(shader, loc_time, t);
         if (is_valid_loc(loc_freq))   GuliShaderSetFloat(shader, loc_freq, frequency);
         if (is_valid_loc(loc_speed))  GuliShaderSetFloat(shader, loc_speed, speed);
         if (is_valid_loc(loc_aspect)) GuliShaderSetFloat(shader, loc_aspect, aspect);
 
         GuliDrawFullscreen();
         GuliEndDraw();
     }
 
     exit_code = 0;
 
 cleanup:
     if (shader) GuliShaderUnload(shader);
     GuliShutdown();
 
     if (G_State.error.result != GULI_ERROR_SUCCESS)
         GULI_PRINT_ERROR(G_State.error.result, G_State.error.message);
 
     return exit_code;
}

