#include "Core/guli_core.h"
#ifdef GULI_BACKEND_METAL
#include "Graphics/Metal/guli_metal.h"
#endif
#ifdef GULI_BACKEND_OPENGL
#include "Graphics/OpenGL/guli_gl.h"
#endif

GuliState G_State;

short GuliInit(uint32_t width, uint32_t height, const char* title)
{
    if (!GuliBackendInit())
    {
        GuliSetError(&G_State.error, GULI_ERROR_FAILED, "Failed to initialize Guli");
        GULI_PRINT_ERROR(G_State.error.result, G_State.error.message);
        return G_State.error.result;
    }

#ifdef GULI_BACKEND_METAL
    GuliWindowHint(GULI_CLIENT_API, GULI_NO_API);
#else
    GuliWindowHint(GULI_CLIENT_API, GULI_OPENGL_API);
    GuliWindowHint(GULI_CONTEXT_VERSION_MAJOR, 3);
    GuliWindowHint(GULI_CONTEXT_VERSION_MINOR, 3);
    GuliWindowHint(GULI_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
#endif

    G_State.window = GuliWindowCreate(width, height, title);
    if (!G_State.window)
    {
        GuliSetError(&G_State.error, GULI_ERROR_FAILED, "Failed to create window");
        GULI_PRINT_ERROR(G_State.error.result, G_State.error.message);
        GuliTerminate();
        return G_State.error.result;
    }

#ifdef GULI_BACKEND_METAL
    if (MetalInit(&G_State) != GULI_ERROR_SUCCESS)
        return G_State.error.result;
    fprintf(stdout, "Guli: using Metal backend\n");
#endif
#ifdef GULI_BACKEND_OPENGL
    if (GlInit(&G_State) != GULI_ERROR_SUCCESS)
        return G_State.error.result;
    fprintf(stdout, "Guli: using OpenGL backend\n");
#endif

    GuliSetError(&G_State.error, GULI_ERROR_SUCCESS, NULL);
    return GULI_ERROR_SUCCESS;
}

void GuliShutdown(void)
{
    if (G_State.window)
    {
#ifdef GULI_BACKEND_METAL
        MetalShutdown(&G_State);
#endif
#ifdef GULI_BACKEND_OPENGL
        GlShutdown(&G_State);
#endif
        GuliWindowDestroy();
        G_State.window = NULL;
    }

    GuliTerminate();

    GuliSetError(&G_State.error, GULI_ERROR_SUCCESS, "Guli shutdown successfully");
}
